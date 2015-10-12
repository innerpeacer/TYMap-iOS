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


void showNetworkStrucutue(vector<IPXNode *> nodeArray)
{
    // ============= Test Showing Network ====================
    sort(nodeArray.begin(), nodeArray.end(), node_id_cmp);
    for (vector<IPXNode *>::iterator nodeIter = nodeArray.begin(); nodeIter != nodeArray.end(); ++nodeIter) {
        printf("%d", (int)(*nodeIter)->getNodeID());
        sort((*nodeIter)->adjacencies.begin(), (*nodeIter)->adjacencies.end(), link_id_cmp);
        for (vector<IPXLink *>::iterator linkIter = (*nodeIter)->adjacencies.begin(); linkIter != (*nodeIter)->adjacencies.end(); ++linkIter) {
            printf("->%d",(*linkIter)->getLinkID());
        }
    }
    printf("\n");
    // ============= Test Showing Network ====================
}

IPXRouteNetworkDataset::IPXRouteNetworkDataset(std::vector<IPXNodeRecord> &nodes, std::vector<IPXLinkRecord> &links)
{
//    GeometryEngine *engine;
    m_tempNodeID = 60000;
    m_tempLinkID = 80000;
    
    extractNodes(nodes);
    extractLinks(links);
    processNodesAndLinks();
    
    // ============= Test Showing Network ====================
//    printf("Cpp => Network\n");
//    showNetworkStrucutue(m_nodeArray);
    // ============= Test Showing Network ====================
    
    
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
    printf("Extract %d nodes and %d virtual nodes.\n", (int)m_nodeArray.size(), (int)m_virtualNodeArray.size());
    
//    IPXNodeMap::iterator nodeIter;
//    for (nodeIter = m_allNodeDict.begin() ; nodeIter != m_allNodeDict.end(); ++nodeIter) {
//        printf("%d : %s\n", nodeIter->first, nodeIter->second->toString().c_str());
//    }
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
    printf("Extract %d links and %d virtual links.\n", (int)m_linkArray.size(), (int)m_virtualLinkArray.size());
    
//    IPXLinkMap::iterator linkIter;
//    for (linkIter = m_allLinkDict.begin(); linkIter != m_allLinkDict.end(); ++linkIter) {
//        printf("%s : %s\n", linkIter->first.c_str(), linkIter->second->toString().c_str());
//    }
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
//    printf("CPP => Total %d nods in path\n", (int)nodeArray.size());

    reverse(nodeArray.begin(), nodeArray.end());
    
    stringstream ostr;
    CoordinateArraySequence sequence;
    
//    printf("CPP => getShorestPathToNode\n");
    for (vector<IPXNode *>::iterator iter = nodeArray.begin(); iter != nodeArray.end(); ++iter) {
        IPXNode *node = (*iter);
        
        if (node != NULL && node->previousNode != NULL) {
            printf(" -> %d(%d)", node->getNodeID(), (int)node->adjacencies.size());
            
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
    printf("\n");
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
//    printf("  startPoint: %f, %f\n", startPoint->getX(), startPoint->getY());
    
    m_tempStartLinkArray.clear();
    m_tempStartNodeArray.clear();
    m_replacedStartLinkArray.clear();
    
    
    // Add New Node If Needed
    GeometryFactory factory;
    CoordinateSequence *sequences = geos::operation::distance::DistanceOp::nearestPoints(m_unionLine, startPoint);
    geos::geom::Point *np = NULL;
    if (sequences->size() > 0) {
        Coordinate coord;
        coord.x = sequences->front().x;
        coord.y = sequences->front().y;
        np = factory.createPoint(coord);
    }
    delete sequences;
    
    
//    printf("nearestPoint: %f, %f\n", np->getX(), np->getY());
//    printf("nearestPoint: %f, %f\n", np->getX(), np->getY());

    
    vector<IPXNode *>::iterator iter;
    for (iter = m_nodeArray.begin(); iter != m_nodeArray.end(); ++iter) {
        if ((*iter)->getPos()->contains(np)) {
            printf("Start Point Equal to One of the Nodes!\n");
            delete np;
            return (*iter);
        }
    }
    
    IPXNode *newTempNode = new IPXNode(m_tempNodeID, false);
    m_tempNodeID++;
    newTempNode->setPos(np);
    m_tempStartNodeArray.push_back(newTempNode);
    
    
    // Add New Links If Needed
    vector<IPXLink *>::iterator linkIter;
    for (linkIter = m_linkArray.begin(); linkIter != m_linkArray.end(); ++linkIter) {
        IPXLink *link = (*linkIter);
        
        Coordinate coord;
        coord.x = np->getX();
        coord.y = np->getY();
        
        geos::linearref::LinearLocation location = geos::linearref::LocationIndexOfPoint::indexOf(link->getLine(), coord);
        int index = location.getSegmentIndex();
        
        if (!location.isVertex()) {
            printf("Index: %d Link: %d\n", index, link->getLinkID());

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
            
            printf("Add Link: %d\n", firstPartLink->getLinkID());
            printf("Add Link: %d\n", secondPartLink->getLinkID());

            m_tempStartLinkArray.push_back(firstPartLink);
            m_tempStartLinkArray.push_back(secondPartLink);
            m_replacedStartLinkArray.push_back(link);
        }
    }
    
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
        
        printf("Remove Link: %d\n", replacedLink->getLinkID());
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
    m_tempEndNodeArray.clear();
    m_tempEndLinkArray.clear();
    m_replacedEndLinkArray.clear();
    
    
    // Add New Node If Needed
    GeometryFactory factory;
    CoordinateSequence *sequences = geos::operation::distance::DistanceOp::nearestPoints(m_unionLine, endPoint);
    geos::geom::Point *np = NULL;
    if (sequences->size() > 0) {
        Coordinate coord;
        coord.x = sequences->front().x;
        coord.y = sequences->front().y;
        np = factory.createPoint(coord);
    }
    delete sequences;
    
    vector<IPXNode *>::iterator iter;
    for (iter = m_nodeArray.begin(); iter != m_nodeArray.end(); ++iter) {
        if ((*iter)->getPos()->contains(np)) {
            printf("End Point Equal to One of the Nodes!\n");
            delete np;
            return (*iter);
        }
    }
    
    IPXNode *newTempNode = new IPXNode(m_tempNodeID, false);
    m_tempNodeID++;
    newTempNode->setPos(np);
    
    m_tempEndNodeArray.push_back(newTempNode);
    
    
    // Add New Links If Needed
    vector<IPXLink *>::iterator linkIter;
    for (linkIter = m_linkArray.begin(); linkIter != m_linkArray.end(); ++linkIter) {
        IPXLink *link = (*linkIter);

        Coordinate coord;
        coord.x = np->getX();
        coord.y = np->getY();
        
        geos::linearref::LinearLocation location = geos::linearref::LocationIndexOfPoint::indexOf(link->getLine(), coord);
        int index = location.getSegmentIndex();
        
        if (!location.isVertex()) {
            printf("Index: %d Link: %d\n", index, link->getLinkID());

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
            
            printf("Add Link: %d\n", firstPartLink->getLinkID());
            printf("Add Link: %d\n", secondPartLink->getLinkID());

            
            m_tempLinkID++;
            
            m_tempEndLinkArray.push_back(firstPartLink);
            m_tempEndLinkArray.push_back(secondPartLink);
            m_replacedEndLinkArray.push_back(link);
        }
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
        
        printf("Remove Link: %d\n", replacedLink->getLinkID());
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
    
    // ============= Test Showing Network ====================
    printf("Cpp => After Process Start\n");
//    showNetworkStrucutue(m_nodeArray);
    showNetworkStrucutue(m_tempStartNodeArray);

    
    // ============= Test Showing Network ====================
    IPXNode *endNode = processTempNodeForEnd(end);
    
    // ============= Test Showing Network ====================
    printf("Cpp => After Process End\n");
    //    showNetworkStrucutue(m_nodeArray);
    showNetworkStrucutue(m_tempEndNodeArray);
    // ============= Test Showing Network ====================
    
    
//    int ranStart = arc4random() % m_nodeArray.size();
//    int ranEnd = arc4random() % m_nodeArray.size();
//    IPXNode *startNode = m_nodeArray.at(ranStart);
//    IPXNode *endNode = m_nodeArray.at(ranEnd);
    
//    printf("CPP => Start Node: %d\n", startNode->getNodeID());
//    printf("CPP => End Node: %d\n", endNode->getNodeID());

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
    
//    printf("%d points in result path\n", (int)resultSequence.getSize());
    
    resetTempNodeForEnd();
    // ============= Test Showing Network ====================
//    printf("Cpp => After Reset End\n");
//    showNetworkStrucutue(m_nodeArray);
    showNetworkStrucutue(m_tempEndNodeArray);

    // ============= Test Showing Network ====================
    
    resetTempNodeForStart();
    // ============= Test Showing Network ====================
//    printf("Cpp => After Reset Start\n");
//    showNetworkStrucutue(m_nodeArray);
    showNetworkStrucutue(m_tempStartNodeArray);

    // ============= Test Showing Network ====================
    
    return factory.createLineString(resultSequence);
}

std::string IPXRouteNetworkDataset::toString() const
{
    ostringstream ostr;
    ostr << "RouteDataset: " << (int)(m_linkArray.size() + m_virtualLinkArray.size()) << " Links and " << (int)(m_nodeArray.size() + m_virtualNodeArray.size()) << " Nodes";
    return ostr.str();
}

