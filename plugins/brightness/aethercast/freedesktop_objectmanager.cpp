/*
 * This file was generated by qdbusxml2cpp version 0.8
 * Command line was: qdbusxml2cpp -p freedesktop_objectmanager -i aethercast_helper.h -v -c DBusObjectManagerInterface org.freedesktop.DBus.ObjectManager.xml
 *
 * qdbusxml2cpp is Copyright (C) 2015 Digia Plc and/or its subsidiary(-ies).
 *
 * This is an auto-generated file.
 * This file may have been hand-edited. Look for HAND-EDIT comments
 * before re-generating it.
 */

#include "freedesktop_objectmanager.h"

/*
 * Implementation of interface class DBusObjectManagerInterface
 */

DBusObjectManagerInterface::DBusObjectManagerInterface(const QString &service, const QString &path, const QDBusConnection &connection, QObject *parent)
    : QDBusAbstractInterface(service, path, staticInterfaceName(), connection, parent)
{
}

DBusObjectManagerInterface::~DBusObjectManagerInterface()
{
}

