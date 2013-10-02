/*
 * This file is part of system-settings
 *
 * Copyright (C) 2013 Canonical Ltd.
 *
 * Contact: William Hua <william.hua@canonical.com>
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

#include "keyboard-layout.h"
#include <QtXmlPatterns>

KeyboardLayout::KeyboardLayout(const QString &name,
                               const QString &language,
                               const QString &displayName,
                               const QString &shortName,
                               QObject       *parent) :
    QObject(parent),
    _name(name),
    _language(language),
    _displayName(displayName),
    _shortName(shortName)
{
}

KeyboardLayout::KeyboardLayout(const QFileInfo &fileInfo,
                               QObject         *parent) :
    QObject(parent),
    _name(fileInfo.completeBaseName())
{
    QVariant path(fileInfo.canonicalFilePath());

    QXmlQuery languageQuery;
    languageQuery.bindVariable("path", path);
    languageQuery.setQuery("xs:string(doc($path)/keyboard/@language)");

    QStringList languageResults;

    if (languageQuery.evaluateTo(&languageResults) && !languageResults.isEmpty())
        _language = languageResults.first();

    QXmlQuery titleQuery;
    titleQuery.bindVariable("path", path);
    titleQuery.setQuery("xs:string(doc($path)/keyboard/@title)");

    QStringList titleResults;

    if (titleQuery.evaluateTo(&titleResults) && !titleResults.isEmpty())
        _displayName = titleResults.first();

    _shortName = _language.left(2);
    _shortName[0] = _shortName[0].toUpper();
}

const QString &
KeyboardLayout::name() const
{
    return _name;
}

const QString &
KeyboardLayout::language() const
{
    return _language;
}

const QString &
KeyboardLayout::displayName() const
{
    return _displayName;
}

const QString &
KeyboardLayout::shortName() const
{
    return _shortName;
}