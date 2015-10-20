//
//  IPXRouteNetworkDataset.cpp
//  MapProject
//
//  Created by innerpeacer on 15/10/11.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#include "IPXRouteNetworkDataset.hpp"

#include <sstream>
#include <algorithm>

#include <geos/operation/union/CascadedUnion.h>
#include <geos/operation/distance/DistanceOp.h>
#include <geos/linearref/LocationIndexOfPoint.h>
#include <geos/linearref/LinearLocation.h>

using namespace Innerpeacer::MapSDK;
using namespace std;

typedef unordered_map<int, IPXNode *> IPXNodeMap;
typedef unordered_map<std::string, IPXLink *> IPXLinkMap;


int node_cmp(IPXNode *n1, IPXNode *n2)
{
    return n1->minDistance < n2->minDistance;
}

int node_id_cmp(IPXNode *n1, IPXNode *n2)
{
    return n1->getNodeID() < n2->getNodeID();
}

int link_id_cmp(IPXLink *l1, IPXLink *l2)
{
    return l1->getLinkID() < l2->getLinkID();
}

IPXRouteNetworkDataset::IPXRouteNetworkDataset(std::vector<IPXNodeRecord> &nodes, std::vector<IPXLinkRecord> &links)
{
    //    GeometryEngine *engine;
    m_tempNodeID = 60000;
    m_tempLinkID = 80000;
    
    extractNodes(nodes);
    extractLinks(links);
    processNodesAndLinks();
    
    vector<IPXLink *>::iterator iter;
    vector<Geometry *> linkLineVector;
    for (iter = m_linkArray.begin(); iter != m_linkArray.end(); ++iter) {
        IPXLink *link = (*iter);
        linkLineVector.push_back(link->getLine());
    }
    m_unionLine = dynamic_cast<MultiLineString *>(geos::operation::geounion::CascadedUnion::Union(&linkLineVector));
    
}

IPXRouteNetworkDataset::~IPXRouteNetworkDataset()
{
    vector<IPXNode *>::iterator nodeIter;
    for (nodeIter = m_nodeArray.begin(); nodeIter != m_nodeArray.end(); ++nodeIter) {
        delete (*nodeIter);
    }
    
    for (nodeIter = m_virtualNodeArray.begin(); nodeIter != m_virtualNodeArray.end(); ++nodeIter) {
        delete (*nodeIter);
    }
    
    vector<IPXLink *>::iterator linkIter;
    for (linkIter = m_linkArray.begin(); linkIter != m_linkArray.end(); ++linkIter) {
        delete (*linkIter);
    }
    
    for (linkIter = m_virtualLinkArray.begin(); linkIter != m_virtualLinkArray.end(); ++linkIter) {
        delete (*linkIter);
    }
    
    if (m_unionLine) {
        delete m_unionLine;
    }
}

#pragma mark Building RouteNetwork
void IPXRouteNetworkDataset::extractNodes(std::vector<IPXNodeRecord> &nodes)
{
    vector<IPXNodeRecord>::iterator iter;
    for (iter = nodes.begin(); iter != nodes.end(); ++iter) {
        IPXNode *node = new IPXNode(iter->nodeID, iter->isVirtual);
        node->setPos(iter->pos);
        
        m_allNodeDict.insert(IPXNodeMap::value_type(iter->nodeID, node));
        
        if (iter->isVirtual) {
            m_virtualNodeArray.push_back(node);
        } else {
            m_nodeArray.push_back(node);
        }
    }
//    printf("Extract %d nodes and %d virtual nodes.\n", (int)m_nodeArray.size(), (int)m_virtualNodeArray.size());
}

void IPXRouteNetworkDataset::extractLinks(std::vector<IPXLinkRecord> &links)
{
    stringstream ostr;
    
    vector<IPXLinkRecord>::iterator iter;
    for (iter = links.begin(); iter != links.end(); ++iter) {
        IPXLink *forwardLink = new IPXLink(iter->linkID, iter->isVirtual);
        forwardLink->currentNodeID = iter->headNode;
        forwardLink->nextNodeID = iter->endNode;
        forwardLink->length = iter->length;
        forwardLink->setLine(iter->line);
        
        ostr.str("");
        ostr << forwardLink->currentNodeID << forwardLink->nextNodeID;
        m_allLinkDict.insert(IPXLinkMap::value_type(ostr.str(), forwardLink));
        
        if (iter->isVirtual) {
            m_virtualLinkArray.push_back(forwardLink);
        } else {
            m_linkArray.push_back(forwardLink);
        }
        
        
        if (!iter->isOneWay) {
            IPXLink *reverseLink = new IPXLink(iter->linkID, iter->isVirtual);
            reverseLink->currentNodeID = iter->endNode;
            reverseLink->nextNodeID = iter->headNode;
            reverseLink->length = iter->length;
            reverseLink->setLine(dynamic_cast<geos::geom::LineString *>(iter->line->reverse()));
            
            ostr.str("");
            ostr << reverseLink->currentNodeID << reverseLink->nextNodeID;
            m_allLinkDict.insert(IPXLinkMap::value_type(ostr.str(), reverseLink));
            
            if (iter->isVirtual) {
                m_virtualLinkArray.push_back(reverseLink);
            } else {
                m_linkArray.push_back(reverseLink);
            }
        }
    }
//    printf("Extract %d links and %d virtual links.\n", (int)m_linkArray.size(), (int)m_virtualLinkArray.size());
}

void IPXRouteNetworkDataset::processNodesAndLinks()
{
    IPXLinkMap::iterator linkIter;
    for (linkIter = m_allLinkDict.begin(); linkIter != m_allLinkDict.end(); ++linkIter) {
        IPXLink *link = linkIter->second;
        IPXNode *headNode = m_allNodeDict.at(link->currentNodeID);
        IPXNode *endNode = m_allNodeDict.at(link->nextNodeID);
        
        headNode->addLink(link);
        link->nextNode = endNode;
    }
}

#pragma mark Dijkstra Algorithm
void IPXRouteNetworkDataset::computePaths(IPXNode *source)
{
    source->minDistance = 0;
    
    vector<IPXNode *> nodeQueue;
    nodeQueue.push_back(source);
    
    while (nodeQueue.size() > 0) {
        sort(nodeQueue.begin(), nodeQueue.end(), node_cmp);
        
        IPXNode *u = nodeQueue.front();
        nodeQueue.erase(nodeQueue.begin());
        
        vector<IPXLink *>::iterator linkIter;
        for (linkIter = u->adjacencies.begin(); linkIter != u->adjacencies.end(); ++linkIter) {
            IPXLink *e = (*linkIter);
            IPXNode *v = e->nextNode;
            
            double length = e->length;
            double distanceThroughU = u->minDistance + length;
            
            if (distanceThroughU < v->minDistance) {
                for (vector<IPXNode *>::iterator nodeIter = nodeQueue.begin(); nodeIter != nodeQueue.end(); ++nodeIter) {
                    if ((*nodeIter) == v) {
                        nodeQueue.erase(nodeIter);
                        break;
                    }
                }
                
                v->minDistance = distanceThroughU;
                v->previousNode = u;
                nodeQueue.push_back(v);
            }
        }
    }
}

geos::geom::LineString *IPXRouteNetworkDataset::getShorestPathToNode(IPXNode *target)
{
    vector<IPXNode *> nodeArray;
    for (IPXNode *node = target; node != NULL; node = node->previousNode) {
        nodeArray.push_back(node);
    }
    reverse(nodeArray.begin(), nodeArray.end());
    
    stringstream ostr;
    CoordinateArraySequence sequence;
    
    for (vector<IPXNode *>::iterator iter = nodeArray.begin(); iter != nodeArray.end(); ++iter) {
        IPXNode *node = (*iter);
        
        if (node != NULL && node->previousNode != NULL) {            
            ostr.str("");
            ostr << node->previousNode->getNodeID() << node->getNodeID();
            string key = ostr.str();
            
            IPXLink *link = m_allLinkDict.at(key);
            LineString *linkLine = link->getLine();
            for (int i = 0; i < linkLine->getNumPoints(); ++i) {
                sequence.add(linkLine->getCoordinateN(i));
            }
        }
    }
    sequence.removeRepeatedPoints();
    
    GeometryFactory factory;
    LineString *resultLine = factory.createLineString(sequence);
    return resultLine;
}

void IPXRouteNetworkDataset::reset()
{
    vector<IPXNode *>::iterator iter;
    for (iter = m_nodeArray.begin(); iter != m_nodeArray.end(); ++iter) {
        (*iter)->reset();
    }
    
    for (iter = m_virtualNodeArray.begin(); iter != m_virtualNodeArray.end(); ++iter) {
        (*iter)->reset();
    }
}


#pragma mark Route Processing

IPXNode *IPXRouteNetworkDataset::processTempNodeForStart(geos::geom::Point *startPoint)
{
    m_tempStartLinkArray.clear();
    m_tempStartNodeArray.clear();
    m_replacedStartLinkArray.clear();
    
//    printf("Start Point: %f, %f\n", startPoint->getX(), startPoint->getY());
    
    // Add New Node If Needed
    GeometryFactory factory;
    CoordinateSequence *sequences = geos::operation::distance::DistanceOp::nearestPoints(m_unionLine, startPoint);
    geos::geom::Point *npOnUnionLine = NULL;
    if (sequences->size() > 0) {
        Coordinate onUnionCoord;
        onUnionCoord.x = sequences->front().x;
        onUnionCoord.y = sequences->front().y;
        npOnUnionLine = factory.createPoint(onUnionCoord);
    }
    delete sequences;
    
//    printf("npOnUnionLine Point: %f, %f\n", npOnUnionLine->getX(), npOnUnionLine->getY());

    
    vector<IPXNode *>::iterator iter;
    for (iter = m_nodeArray.begin(); iter != m_nodeArray.end(); ++iter) {
        double distance = (*iter)->getPos()->distance(npOnUnionLine);
        if (distance == 0) {
            //        if ((*iter)->getPos()->contains(np)) {
//            printf("Start Point Equal to One of the Nodes!\n");
            delete npOnUnionLine;
            return (*iter);
        }
    }
    
//    printf("Create New Temp Node: %d\n", m_tempNodeID);
    IPXNode *newTempNode = new IPXNode(m_tempNodeID, false);
    m_tempNodeID++;
    newTempNode->setPos(npOnUnionLine);
    m_tempStartNodeArray.push_back(newTempNode);
    
    // Add New Links If Needed
    vector<IPXLink *>::iterator linkIter;
    for (linkIter = m_linkArray.begin(); linkIter != m_linkArray.end(); ++linkIter) {
        IPXLink *link = (*linkIter);
        
        if (link->getLine()->contains(npOnUnionLine)) {
//printf("Contain\n");
        } else {
            double distance = link->getLine()->distance(npOnUnionLine);
            if (distance < 0.001 && distance > 0) {
//                printf("Contain: %.10f\n", distance);
            } else {
                // npOnUnionLine is First or Last Vertex
                // npOnUnionLine unrelated to Link
                continue;
            }
        }
        
        CoordinateSequence *sequences = geos::operation::distance::DistanceOp::nearestPoints(link->getLine(), npOnUnionLine);
        geos::geom::Point *npOnLink = NULL;
        if (sequences->size() > 0) {
            Coordinate onLinkCoord;
            onLinkCoord.x = sequences->front().x;
            onLinkCoord.y = sequences->front().y;
            npOnLink = factory.createPoint(onLinkCoord);
        }
        delete sequences;
        
        if (!link->getLine()->contains(npOnLink) && link->getLine()->distance(npOnLink) == 0) {
//            printf("Wrong Link");
            continue;
        }
        
        Coordinate coord;
        coord.x = npOnLink->getX();
        coord.y = npOnLink->getY();
        
        geos::linearref::LinearLocation location = geos::linearref::LocationIndexOfPoint::indexOf(link->getLine(), coord);
        int index = location.getSegmentIndex();
        
        CoordinateArraySequence firstPartSequence;
        CoordinateArraySequence secondPartSequence;
        
        secondPartSequence.add(coord);
//        printf("coord: %f, %f\n", coord.x, coord.y);
//        printf("link->getLine()->getNumPoints(): %d\n", (int)link->getLine()->getNumPoints());
        for (int i = 0; i < link->getLine()->getNumPoints(); ++i) {
//            printf("coord: %f, %f\n", link->getLine()->getCoordinateN(i).x, link->getLine()->getCoordinateN(i).y);

            if (i <= index) {
                firstPartSequence.add(link->getLine()->getCoordinateN(i));
            } else {
                secondPartSequence.add(link->getLine()->getCoordinateN(i));
            }
        }
        firstPartSequence.add(coord);
        
        firstPartSequence.removeRepeatedPoints();
        secondPartSequence.removeRepeatedPoints();
        
//        printf("%d\n", (int)firstPartSequence.size());
//        printf("%d\n", (int)secondPartSequence.size());
        
//        printf("===================\n");
        
        LineString *firstPartLineString = factory.createLineString(firstPartSequence);
        LineString *secondPartLineString = factory.createLineString(secondPartSequence);
        
        IPXLink *firstPartLink = new IPXLink(m_tempLinkID, false);
        firstPartLink->currentNodeID = link->currentNodeID;
        firstPartLink->nextNodeID = newTempNode->getNodeID();
        firstPartLink->length = firstPartLineString->getLength();
        firstPartLink->setLine(firstPartLineString);
        
        IPXLink *secondPartLink = new IPXLink(m_tempLinkID, false);
        secondPartLink->currentNodeID = newTempNode->getNodeID();
        secondPartLink->nextNodeID = link->nextNodeID;
        secondPartLink->length = secondPartLineString->getLength();
        secondPartLink->setLine(secondPartLineString);
        
        m_tempLinkID++;
        
        m_tempStartLinkArray.push_back(firstPartLink);
        m_tempStartLinkArray.push_back(secondPartLink);
        m_replacedStartLinkArray.push_back(link);
        
        delete npOnLink;
    }
    
//    printf("m_tempStartLinkArray: %d\n", (int)m_tempStartLinkArray.size());
//    printf("m_replacedStartLinkArray: %d\n", (int)m_replacedStartLinkArray.size());
//    printf("m_tempStartNodeArray: %d\n", (int)m_tempStartNodeArray.size());

    stringstream ostr;
    
    for (vector<IPXNode *>::iterator nodeIter = m_tempStartNodeArray.begin(); nodeIter != m_tempStartNodeArray.end(); ++nodeIter) {
        m_allNodeDict.insert(IPXNodeMap::value_type(newTempNode->getNodeID(), newTempNode));
    }
    
    for (vector<IPXLink *>::iterator linkIter = m_tempStartLinkArray.begin(); linkIter != m_tempStartLinkArray.end(); ++linkIter) {
        IPXLink *newLink = (*linkIter);
        
        IPXNode *headNode = m_allNodeDict.at(newLink->currentNodeID);
        headNode->addLink(newLink);
        newLink->nextNode = m_allNodeDict.at(newLink->nextNodeID);
        
        ostr.str("");
        ostr << newLink->currentNodeID << newLink->nextNodeID;
        string newLinkKey = ostr.str();
        m_allLinkDict.insert(IPXLinkMap::value_type(newLinkKey, newLink));
        
        m_linkArray.push_back(newLink);
    }
    
    for (vector<IPXLink *>::iterator linkIter = m_replacedStartLinkArray.begin(); linkIter != m_replacedStartLinkArray.end(); ++linkIter) {
        IPXLink *replacedLink = (*linkIter);
        
        IPXNode *headNode = m_allNodeDict.at(replacedLink->currentNodeID);
        headNode->removeLink(replacedLink);
        
        ostr.str("");
        ostr << replacedLink->currentNodeID << replacedLink->nextNodeID;
        string replacedLinkKey = ostr.str();
        
        m_allLinkDict.erase(replacedLinkKey);
        for (vector<IPXLink *>::iterator rpIter = m_linkArray.begin(); rpIter != m_linkArray.end(); ++rpIter) {
            if ((*rpIter) == replacedLink) {
                m_linkArray.erase(rpIter);
                break;
            }
        }
    }
    
    return newTempNode;
}

IPXNode *IPXRouteNetworkDataset::processTempNodeForEnd(geos::geom::Point *endPoint)
{
    m_tempEndLinkArray.clear();
    m_tempEndNodeArray.clear();
    m_replacedEndLinkArray.clear();
    
    // Add New Node If Needed
    GeometryFactory factory;
    CoordinateSequence *sequences = geos::operation::distance::DistanceOp::nearestPoints(m_unionLine, endPoint);
    geos::geom::Point *npOnUnionLine = NULL;
    if (sequences->size() > 0) {
        Coordinate onUnionCoord;
        onUnionCoord.x = sequences->front().x;
        onUnionCoord.y = sequences->front().y;
        npOnUnionLine = factory.createPoint(onUnionCoord);
    }
    delete sequences;
    
    vector<IPXNode *>::iterator iter;
    for (iter = m_nodeArray.begin(); iter != m_nodeArray.end(); ++iter) {
        double distance = (*iter)->getPos()->distance(npOnUnionLine);
        if (distance == 0) {
            //        if ((*iter)->getPos()->contains(np)) {
//            printf("End Point Equal to One of the Nodes!\n");
            delete npOnUnionLine;
            return (*iter);
        }
    }
    
    IPXNode *newTempNode = new IPXNode(m_tempNodeID, false);
    m_tempNodeID++;
    newTempNode->setPos(npOnUnionLine);
    m_tempEndNodeArray.push_back(newTempNode);
    
    
    // Add New Links If Needed
    vector<IPXLink *>::iterator linkIter;
    for (linkIter = m_linkArray.begin(); linkIter != m_linkArray.end(); ++linkIter) {
        IPXLink *link = (*linkIter);
        
        if (link->getLine()->contains(npOnUnionLine)) {
            //            printf("Contain\n");
        } else {
            double distance = link->getLine()->distance(npOnUnionLine);
            if (distance < 0.001 && distance > 0) {
                //                printf("Contain: %.10f", distance);
            } else {
                // npOnUnionLine is First or Last Vertex
                continue;
            }
        }
        
        CoordinateSequence *sequences = geos::operation::distance::DistanceOp::nearestPoints(link->getLine(), npOnUnionLine);
        geos::geom::Point *npOnLink = NULL;
        if (sequences->size() > 0) {
            Coordinate onLinkCoord;
            onLinkCoord.x = sequences->front().x;
            onLinkCoord.y = sequences->front().y;
            npOnLink = factory.createPoint(onLinkCoord);
        }
        delete sequences;
        
        if (!link->getLine()->contains(npOnLink) && link->getLine()->distance(npOnLink) == 0) {
            //            printf("Wrong Link");
            continue;
        }
        
        Coordinate coord;
        coord.x = npOnLink->getX();
        coord.y = npOnLink->getY();
        
        geos::linearref::LinearLocation location = geos::linearref::LocationIndexOfPoint::indexOf(link->getLine(), coord);
        int index = location.getSegmentIndex();
        
        CoordinateArraySequence firstPartSequence;
        CoordinateArraySequence secondPartSequence;
        
        secondPartSequence.add(coord);
        for (int i = 0; i < link->getLine()->getNumPoints(); ++i) {
            if (i <= index) {
                firstPartSequence.add(link->getLine()->getCoordinateN(i));
            } else {
                secondPartSequence.add(link->getLine()->getCoordinateN(i));
            }
        }
        firstPartSequence.add(coord);
        
        firstPartSequence.removeRepeatedPoints();
        secondPartSequence.removeRepeatedPoints();
        
        LineString *firstPartLineString = factory.createLineString(firstPartSequence);
        LineString *secondPartLineString = factory.createLineString(secondPartSequence);
        
        IPXLink *firstPartLink = new IPXLink(m_tempLinkID, false);
        firstPartLink->currentNodeID = link->currentNodeID;
        firstPartLink->nextNodeID = newTempNode->getNodeID();
        firstPartLink->length = firstPartLineString->getLength();
        firstPartLink->setLine(firstPartLineString);
        
        IPXLink *secondPartLink = new IPXLink(m_tempLinkID, false);
        secondPartLink->currentNodeID = newTempNode->getNodeID();
        secondPartLink->nextNodeID = link->nextNodeID;
        secondPartLink->length = secondPartLineString->getLength();
        secondPartLink->setLine(secondPartLineString);
        
        m_tempLinkID++;
                
        m_tempEndLinkArray.push_back(firstPartLink);
        m_tempEndLinkArray.push_back(secondPartLink);
        m_replacedEndLinkArray.push_back(link);
        
        delete npOnLink;
    }
    
    stringstream ostr;
    
    for (vector<IPXNode *>::iterator nodeIter = m_tempEndNodeArray.begin(); nodeIter != m_tempEndNodeArray.end(); ++nodeIter) {
        m_allNodeDict.insert(IPXNodeMap::value_type(newTempNode->getNodeID(), newTempNode));
    }
    
    for (vector<IPXLink *>::iterator linkIter = m_tempEndLinkArray.begin(); linkIter != m_tempEndLinkArray.end(); ++linkIter) {
        IPXLink *newLink = (*linkIter);
        
        IPXNode *headNode = m_allNodeDict.at(newLink->currentNodeID);
        headNode->addLink(newLink);
        newLink->nextNode = m_allNodeDict.at(newLink->nextNodeID);
        
        ostr.str("");
        ostr << newLink->currentNodeID << newLink->nextNodeID;
        string newLinkKey = ostr.str();
        m_allLinkDict.insert(IPXLinkMap::value_type(newLinkKey, newLink));
        
        m_linkArray.push_back(newLink);
    }
    
    for (vector<IPXLink *>::iterator linkIter = m_replacedEndLinkArray.begin(); linkIter != m_replacedEndLinkArray.end(); ++linkIter) {
        IPXLink *replacedLink = (*linkIter);
        
        IPXNode *headNode = m_allNodeDict.at(replacedLink->currentNodeID);
        headNode->removeLink(replacedLink);
        
        ostr.str("");
        ostr << replacedLink->currentNodeID << replacedLink->nextNodeID;
        string replacedLinkKey = ostr.str();
        
        m_allLinkDict.erase(replacedLinkKey);
        for (vector<IPXLink *>::iterator rpIter = m_linkArray.begin(); rpIter != m_linkArray.end(); ++rpIter) {
            if ((*rpIter) == replacedLink) {
                m_linkArray.erase(rpIter);
                break;
            }
        }
    }
    
    return newTempNode;
}


void IPXRouteNetworkDataset::resetTempNodeForStart()
{
    stringstream ostr;
    for (vector<IPXLink *>::iterator linkIter = m_replacedStartLinkArray.begin(); linkIter != m_replacedStartLinkArray.end(); ++linkIter) {
        
        IPXLink *replacedLink = (*linkIter);
        IPXNode *headNode = m_allNodeDict.at(replacedLink->currentNodeID);
        headNode->addLink(replacedLink);
        
        ostr.str("");
        ostr << replacedLink->currentNodeID << replacedLink->nextNodeID;
        string replacedLinkKey = ostr.str();
        
        m_allLinkDict.insert(IPXLinkMap::value_type(replacedLinkKey, replacedLink));
        m_linkArray.push_back(replacedLink);
    }
    
    for (vector<IPXLink *>::iterator linkIter = m_tempStartLinkArray.begin(); linkIter != m_tempStartLinkArray.end(); ++linkIter) {
        
        IPXLink *newLink = (*linkIter);
        
        IPXNode *headNode = m_allNodeDict.at(newLink->currentNodeID);
        headNode->removeLink(newLink);
        newLink->nextNode = NULL;
        
        
        newLink->nextNode = m_allNodeDict.at(newLink->nextNodeID);
        
        ostr.str("");
        ostr << newLink->currentNodeID << newLink->nextNodeID;
        string newLinkKey = ostr.str();
        
        m_allLinkDict.erase(newLinkKey);
        for (vector<IPXLink *>::iterator rpIter = m_linkArray.begin(); rpIter != m_linkArray.end(); ++rpIter) {
            if ((*rpIter) == newLink) {
                m_linkArray.erase(rpIter);
                break;
            }
        }
        
        // 清理临时Link内存，避免内存泄漏
        delete newLink;
    }
    
    for (vector<IPXNode *>::iterator nodeIter = m_tempStartNodeArray.begin(); nodeIter != m_tempStartNodeArray.end(); ++nodeIter) {
        m_allNodeDict.erase((*nodeIter)->getNodeID());
        delete (*nodeIter);
    }
    
    
    m_replacedStartLinkArray.clear();
    m_tempStartLinkArray.clear();
    m_tempStartNodeArray.clear();
    
}

void IPXRouteNetworkDataset::resetTempNodeForEnd()
{
    stringstream ostr;
    for (vector<IPXLink *>::iterator linkIter = m_replacedEndLinkArray.begin(); linkIter != m_replacedEndLinkArray.end(); ++linkIter) {
        
        IPXLink *replacedLink = (*linkIter);
        IPXNode *headNode = m_allNodeDict.at(replacedLink->currentNodeID);
        headNode->addLink(replacedLink);
        
        ostr.str("");
        ostr << replacedLink->currentNodeID << replacedLink->nextNodeID;
        string replacedLinkKey = ostr.str();
        
        m_allLinkDict.insert(IPXLinkMap::value_type(replacedLinkKey, replacedLink));
        m_linkArray.push_back(replacedLink);
    }
    
    for (vector<IPXLink *>::iterator linkIter = m_tempEndLinkArray.begin(); linkIter != m_tempEndLinkArray.end(); ++linkIter) {
        
        IPXLink *newLink = (*linkIter);
        
        IPXNode *headNode = m_allNodeDict.at(newLink->currentNodeID);
        headNode->removeLink(newLink);
        newLink->nextNode = NULL;
        
        
        newLink->nextNode = m_allNodeDict.at(newLink->nextNodeID);
        
        ostr.str("");
        ostr << newLink->currentNodeID << newLink->nextNodeID;
        string newLinkKey = ostr.str();
        
        m_allLinkDict.erase(newLinkKey);
        for (vector<IPXLink *>::iterator rpIter = m_linkArray.begin(); rpIter != m_linkArray.end(); ++rpIter) {
            if ((*rpIter) == newLink) {
                m_linkArray.erase(rpIter);
                break;
            }
        }
        
        // 清理临时Link内存，避免内存泄漏
        delete newLink;
    }
    
    for (vector<IPXNode *>::iterator nodeIter = m_tempEndNodeArray.begin(); nodeIter != m_tempEndNodeArray.end(); ++nodeIter) {
        m_allNodeDict.erase((*nodeIter)->getNodeID());
        delete (*nodeIter);
    }
    
    
    m_replacedEndLinkArray.clear();
    m_tempEndLinkArray.clear();
    m_tempEndNodeArray.clear();
}

IPXNode *IPXRouteNetworkDataset::getTempNode(geos::geom::Point point)
{
    GeometryFactory factory;
    CoordinateSequence *sequences = geos::operation::distance::DistanceOp::nearestPoints(m_unionLine, &point);
    geos::geom::Point *np = NULL;
    if (sequences->size() > 0) {
        Coordinate coord;
        coord.x = sequences->front().x;
        coord.y = sequences->front().y;
        np = factory.createPoint();
    }
    delete sequences;
    
    vector<IPXNode *>::iterator iter;
    for (iter = m_nodeArray.begin(); iter != m_nodeArray.end(); ++iter) {
        if ((*iter)->getPos()->contains(np)) {
            printf("Existing Node\n");
            delete np;
            return (*iter);
        }
    }
    
    IPXNode *newTempNode = new IPXNode(m_tempNodeID, false);
    m_tempNodeID++;
    newTempNode->setPos(np);
    return newTempNode;
}

std::vector<IPXLink *> IPXRouteNetworkDataset::getTempLinks(geos::geom::Point point)
{
    GeometryFactory factory;
    CoordinateSequence *sequences = geos::operation::distance::DistanceOp::nearestPoints(m_unionLine, &point);
    geos::geom::Point *np = NULL;
    if (sequences->size() > 0) {
        Coordinate coord;
        coord.x = sequences->front().x;
        coord.y = sequences->front().y;
        np = factory.createPoint();
    }
    delete sequences;
    
    vector<IPXNode *>::iterator iter;
    for (iter = m_nodeArray.begin(); iter != m_nodeArray.end(); ++iter) {
        if ((*iter)->getPos()->contains(np)) {
            printf("Existing Links: %d\n", (int)(*iter)->adjacencies.size());
            delete np;
            return (*iter)->adjacencies;
        }
    }
    
    vector<IPXLink *> tempLinkArray;
    vector<IPXLink *>::iterator linkIter;
    for (linkIter = m_linkArray.begin(); linkIter != m_linkArray.end(); ++linkIter) {
        IPXLink *link = (*linkIter);
        
        Coordinate coord;
        coord.x = np->getX();
        coord.y = np->getY();
        
        geos::linearref::LinearLocation location = geos::linearref::LocationIndexOfPoint::indexOf(link->getLine(), coord);
        int index = location.getSegmentIndex();
        
        if (!location.isVertex()) {
            
            CoordinateArraySequence firstPartSequence;
            CoordinateArraySequence secondPartSequence;
            
            secondPartSequence.add(coord);
            for (int i = 0; i < link->getLine()->getNumPoints(); ++i) {
                if (i <= index) {
                    firstPartSequence.add(link->getLine()->getCoordinateN(i));
                } else {
                    secondPartSequence.add(link->getLine()->getCoordinateN(i));
                }
            }
            firstPartSequence.add(coord);
            
            firstPartSequence.removeRepeatedPoints();
            secondPartSequence.removeRepeatedPoints();
            
            LineString *firstPartLineString = factory.createLineString(firstPartSequence);
            LineString *secondPartLineString = factory.createLineString(secondPartSequence);
            
            IPXLink *firstPartLink = new IPXLink(m_tempLinkID, false);
            IPXLink *secondPartLink = new IPXLink(m_tempLinkID, false);
            
            firstPartLink->setLine(firstPartLineString);
            secondPartLink->setLine(secondPartLineString);
            
            m_tempLinkID++;
            
            tempLinkArray.push_back(firstPartLink);
            tempLinkArray.push_back(secondPartLink);
            
        }
    }
    
    return tempLinkArray;
}



#pragma mark Public Method
geos::geom::LineString *IPXRouteNetworkDataset::getShorestPath(geos::geom::Point *start, geos::geom::Point *end)
{
    GeometryFactory factory;
    
    reset();
    
    IPXNode *startNode = processTempNodeForStart(start);
    IPXNode *endNode = processTempNodeForEnd(end);
    
    computePaths(startNode);
    LineString *nodePath = getShorestPathToNode(endNode);
    
    if (nodePath->getNumPoints() == 0) {
        delete nodePath;
        return NULL;
    }
    
    CoordinateArraySequence resultSequence;
    
    if (startNode->getPos()->distance(start) > 0) {
        Coordinate startCoord;
        startCoord.x = start->getX();
        startCoord.y = start->getY();
        resultSequence.add(startCoord);
    }
    
    for (int i = 0; i < nodePath->getNumPoints(); ++i) {
        resultSequence.add(nodePath->getCoordinateN(i));
    }
    
    if (endNode->getPos()->distance(end) > 0) {
        Coordinate endCoord;
        endCoord.x = end->getX();
        endCoord.y = end->getY();
        resultSequence.add(endCoord);
    }
    delete nodePath;
    
    resetTempNodeForEnd();
    resetTempNodeForStart();
    
    return factory.createLineString(resultSequence);
}

std::string IPXRouteNetworkDataset::toString() const
{
    ostringstream ostr;
    ostr << "RouteDataset: " << (int)(m_linkArray.size() + m_virtualLinkArray.size()) << " Links and " << (int)(m_nodeArray.size() + m_virtualNodeArray.size()) << " Nodes";
    return ostr.str();
}

