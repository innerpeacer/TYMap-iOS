//
//  IPXLink.cpp
//  MapProject
//
//  Created by innerpeacer on 15/10/11.
//  Copyright © 2015年 innerpeacer. All rights reserved.
//

#include "IPXLink.hpp"
#include <sstream>

using namespace Innerpeacer::MapSDK;
using namespace std;

IPXLink::IPXLink(int linkID, bool isVir)
{
    m_linkID = linkID;
    m_isVirtual = isVir;
    m_line = NULL;
    
    nextNode = NULL;
}

IPXLink::~IPXLink()
{
    if (m_line) {
        delete m_line;
    }
}

int IPXLink::getLinkID() const
{
    return m_linkID;
}

bool IPXLink::isVirtual() const
{
    return m_isVirtual;
}

void IPXLink::setLine(geos::geom::LineString *line)
{
    if (m_line) {
        delete m_line;
    }
    m_line = line;
}

geos::geom::LineString *IPXLink::getLine() const
{
    return m_line;
}

std::string IPXLink::toString() const
{
    ostringstream ostr;
    ostr << "LinkID: " << m_linkID << ", Current: " << currentNodeID << ", Next: " << nextNodeID << ", Length: " << length;
    return ostr.str();
}