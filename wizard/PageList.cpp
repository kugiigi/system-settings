/*
 * This file is part of system-settings
 *
 * Copyright (C) 2014 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * This class lets the list of wizard pages be dynamic.
 * - To add new ones, drop them into
 *   $XDG_DATA_DIRS/ubuntu/settings/wizard/qml/Pages with a numbered prefix,
 *   like "21-custom-page.qml".  The number determines the order in the page
 *   sequence that your page will appear.
 * - To disable an existing page, add a file like "21-custom-page.qml.disabled"
 * - To go to the next page, use pageStack.next()
 * - To go back to the previous page, use pageStack.prev()
 * - To load a page outside of the normal flow (so that it doesn't affect the
 *   back button), use pageStack.push(Qt.resolvedUrl("custom-page.qml")) in
 *   your page.
 * - See default pages for plenty of examples.
 */

#include "PageList.h"
#include <QDir>
#include <QStandardPaths>

#include <QDebug>
PageList::PageList(QObject *parent)
    : QObject(parent),
      m_index(-1),
      m_pages()
{
    QStringList dataDirs = QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation);
    Q_FOREACH(const QString &dataDir, dataDirs) {
        QDir dir(dataDir + "/ubuntu/settings/wizard/qml/Pages");
        QStringList entries = dir.entryList(QStringList("[0-9]*"), QDir::Files | QDir::Readable);
        Q_FOREACH(const QString &entry, entries) {
            if (!m_pages.contains(entry))
                m_pages.insert(entry, dir.absoluteFilePath(entry));
        }
    }

    // Now remove any explicitly disabled entries
    QString disableSuffix = ".disabled";
    Q_FOREACH(const QString &page, m_pages.keys()) {
        if (page.endsWith(disableSuffix)) {
            m_pages.remove(page);
            m_pages.remove(page.left(page.size() - disableSuffix.size()));
        }
    }
}

QStringList PageList::entries() const
{
    return m_pages.keys();
}

QStringList PageList::paths() const
{
    return m_pages.values();
}

int PageList::index() const
{
    return m_index;
}

int PageList::numPages() const
{
    return m_pages.size();
}

QString PageList::prev()
{
    if (m_index > 0)
        return m_pages.values()[setIndex(m_index - 1)];
    else
        return QString();
}

QString PageList::next()
{
    if (m_index < m_pages.count() - 1)
        return m_pages.values()[setIndex(m_index + 1)];
    else
        return QString();
}

int PageList::setIndex(int index)
{
    m_index = index;
    Q_EMIT indexChanged();
    return m_index;
}