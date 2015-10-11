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

using namespace Innerpeacer::MapSDK;
using namespace std;

typedef unordered_map<int, IPXNode *> IPXNodeMap;
typedef unordered_map<std::string, IPXLink *> IPXLinkMap;


int node_cmp(IPXNode *n1, IPXNode *n2)
{
    return n1->minDistance < n2->minDistance;
}

//class IPXRouteNetworkDataset {
//public:
//    IPXRouteNetworkDataset(std::vector<IPXNodeRecord> &nodes, std::vector<IPXLinkRecord> &links);
//    ~IPXRouteNetworkDataset();
//    geos::geom::LineString *getShorestPath(geos::geom::Point start, geos::geom::Point end);
//    std::string toString() const;
//    
//private:
//    void extractNodes(std::vector<IPXNodeRecord> &nodes);
//    void extractLinks(std::vector<IPXLinkRecord> &links);
//    void processNodesAndLinks();
//    
//    void computePaths(IPXNode *source);
//    geos::geom::LineString *getShorestPathToNode(IPXNode *target);
//    void reset();
//    
//    IPXNode *processTempNodeForStart(geos::geom::Point startPoint);
//    IPXNode *processTempNodeForEnd(geos::geom::Point endPoint);
//    void resetTempNodeForStart();
//    void resetTempNodeForEnd();
//    IPXNode getTempNode(geos::geom::Point point);
//    std::vector<IPXLink *>getTempLinks(geos::geom::Point point);
//    
//    geos::geom::LineString *reversePath(geos::geom::LineString *line);
//    
//private:
//    std::vector<IPXLink *> m_linkArray;
//    std::vector<IPXLink *> m_virtualLinkArray;
//    std::vector<IPXNode *> m_nodeArray;
//    std::vector<IPXNode *> m_virtualNodeArray;
//    
//    std::unordered_map<std::string, IPXLink *> m_allLinkDict;
//    std::unordered_map<int, IPXNode *> m_allNodeDict;
//    
//    geos::geom::MultiLineString *m_unionLine;
//    
//    
//private:
//    //            GeometryEngine *engine;
//    std::vector<IPXNode *> tempStartNodeArray;
//    std::vector<IPXLink *> tempStartLinkArray;
//    std::vector<IPXLink *> replacedStartLinkArray;
//    
//    std::vector<IPXNode *> tempEndNodeArray;
//    std::vector<IPXLink *> tempEndLinkArray;
//    std::vector<IPXLink *> replacedEndLinkArray;
//};

//class IPXRouteNetworkDataset {
//
//private:
//    void computePaths(IPXNode *source);
//    geos::geom::LineString *getShorestPathToNode(IPXNode *target);
//    void reset();
//
//    IPXNode *processTempNodeForStart(geos::geom::Point startPoint);
//    IPXNode *processTempNodeForEnd(geos::geom::Point endPoint);
//    void resetTempNodeForStart();
//    void resetTempNodeForEnd();
//    IPXNode getTempNode(geos::geom::Point point);
//    std::vector<IPXLink *>getTempLinks(geos::geom::Point point);
//
//private:
//    geos::geom::MultiLineString *m_unionLine;
//private:
//    //            GeometryEngine *engine;
//};

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


#pragma mark Public Method
geos::geom::LineString *IPXRouteNetworkDataset::getShorestPath(geos::geom::Point start, geos::geom::Point end)
{
    return NULL;
}

std::string IPXRouteNetworkDataset::toString() const
{
    ostringstream ostr;
    ostr << "RouteDataset: " << (int)(m_linkArray.size() + m_virtualLinkArray.size()) << " Links and " << (int)(m_nodeArray.size() + m_virtualNodeArray.size()) << " Nodes";
    return ostr.str();
}

