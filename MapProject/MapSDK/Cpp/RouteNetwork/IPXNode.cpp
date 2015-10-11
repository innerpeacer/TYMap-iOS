//
//  IPXNode.cpp
//  MapProject
//
//  Created by innerpeacer on 15/10/11.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#include "IPXNode.hpp"
#include <sstream>

#define LARGE_DISTANCE 1000000000

using namespace Innerpeacer::MapSDK;
using namespace std;

IPXNode::IPXNode(int nodeID, bool isVir)
{
    m_nodeID = nodeID;
    m_isVirtual = isVir;
    m_pos = NULL;
    
    minDistance = LARGE_DISTANCE;
    previousNode = NULL;
}

IPXNode::~IPXNode()
{
    if (m_pos) {
        delete m_pos;
    }
}

void IPXNode::addLink(IPXLink *link)
{
    adjacencies.push_back(link);
}

void IPXNode::removeLink(IPXLink *link)
{
    vector<IPXLink *>::iterator iter;
    for (iter = adjacencies.begin(); iter != adjacencies.end(); ++iter) {
        if (*iter == link) {
            adjacencies.erase(iter);
            break;
        }
    }
}

void IPXNode::reset()
{
    minDistance = LARGE_DISTANCE;
    previousNode = NULL;
}

int IPXNode::getNodeID() const
{
    return m_nodeID;
}


geos::geom::Point *IPXNode::getPos() const
{
    return m_pos;
}

void IPXNode::setPos(geos::geom::Point *p)
{
    if (m_pos) {
        delete m_pos;
    }
    m_pos = p;
}

std::string IPXNode::toString() const
{
    ostringstream ostr;
    ostr << "NodeID: " << m_nodeID;
    return ostr.str();
}