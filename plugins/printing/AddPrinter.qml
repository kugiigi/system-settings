/*
 * This file is part of system-settings
 *
 * Copyright (C) 2017 Canonical Ltd.
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

import QtQuick 2.4
import SystemSettings 1.0
import SystemSettings.ListItems 1.0 as SettingsListItems
import Ubuntu.Components 1.3
import Ubuntu.Components.Extras.Printers 0.1
import Ubuntu.Components.ListItems 1.3 as ListItems

ItemPage {
    id: addPrinterPage
    objectName: "printingPage"
    title: i18n.tr("Add printer")

    header: PageHeader {
        id: printerHeader
        title: i18n.tr("Printing")
        flickable: addPrinterFlickable
        leadingActionBar {
            actions: [
                Action {
                    id: closeAction
                    iconName: "close"
                    text: i18n.tr("Cancel")
                    onTriggered: pageStack.removePages(addPrinterPage)
                }
            ]
        }
        trailingActionBar {
            actions: [
                Action {
                    id: addAction
                    iconName: "ok"
                    text: i18n.tr("Add printer")
                    enabled: connectionsSelector.selectedIndex > 0
                    onTriggered: {
                        addPrinterPage.state = "adding";
                        var ret;
                        if (driverSelector.selectedIndex == 0) {
                            ret = Printers.addPrinter(
                                nameField.text,
                                driversView.selectedDriver,
                                connections.host,
                                descriptionField.text,
                                locationField.text
                            );
                        } else {
                            ret = Printers.addPrinterWithPpdFile(
                                nameField.text,
                                pddFileField.text,
                                connections.host,
                                descriptionField.text,
                                printerDescription.text,
                                locationField.text
                            );
                        }
                        if (ret) {
                            addPrinterPage.state = "adding"
                        } else {
                            errorMessage.text = Printers.lastMessage;
                            addPrinterPage.state = "failure"
                        }
                    }
                }
            ]
        }
    }

    Component.onCompleted: {
        if (pluginOptions && pluginOptions.connection) {
            switch (pluginOptions.connection) {
                case "ipp":
                    connectionsSelector.selectedIndex = 1;
                    break;
            }
        }

        Printers.prepareToAddPrinter();
    }

    states: [
        State {
            name: "adding"
            PropertyChanges { target: closeAction; enabled: false }
            PropertyChanges { target: addAction; enabled: false }
            PropertyChanges { target: successTimer; running: true }
            PropertyChanges { target: connections; enabled: false }
            PropertyChanges { target: fieldsColumn; enabled: false }
        },
        State {
            name: "failure"
            PropertyChanges { target: errorMessageContainer; visible: true }
        }
    ]

    Flickable {
        id: addPrinterFlickable
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: contentItem.childrenRect.height

        ListItems.ValueSelector {
            id: connectionsSelector
            anchors { left: parent.left; right: parent.right; top: parent.top }
            text: i18n.tr("Connection")
            values: [
                i18n.tr("Choose a connection"),
                "ipp",
                "lpd",
                "ipps",
                "ipp14",
                "http",
                "beh",
                "socket",
                "https",
                "ipp",
                "hp",
                "usb",
                "hpfax",
                "dnssd",
            ]
            onSelectedIndexChanged: {
                if (selectedIndex === 0) {
                    connection.type = PrinterEnum.IppType;
                } else {
                    connection.type = connection.stringToType(values[selectedIndex]);
                }
            }
        }

        Column {
            id: fieldsColumn
            anchors { left: parent.left; right: parent.right; top: connectionsSelector.bottom }
            visible: connectionsSelector.selectedIndex > 0
            height: visible ? childrenRect.height : 0
            clip: true
            property bool enabled: true

            SettingsListItems.Standard {
                text: i18n.tr("Printer name")
                anchors {
                    left: parent.left
                    right: parent.right
                }

                TextField {
                    id: nameField
                    enabled: fieldsColumn.enabled
                }
            }

            Item {
                id: errorMessageContainer
                visible: false
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                }
                height: units.gu(6)
                Label {
                    id: errorMessage
                    anchors {
                        top: parent.top
                        topMargin: units.gu(2)
                        horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            PrinterConnection {
                id: connection
                anchors { left: parent.left; right: parent.right }
                onTypeChanged: {
                    var selIndex = connectionsSelector.values.indexOf(typeToString(type));
                    if (selIndex < 0) {
                        selIndex = 0;
                    }
                    connectionsSelector.selectedIndex = selIndex;
                }
            }

            SettingsListItems.Standard {
                text: i18n.tr("Description")
                anchors { left: parent.left; right: parent.right }

                TextField {
                    id: descriptionField
                    placeholderText: i18n.tr("Optional")
                    enabled: fieldsColumn.enabled
                }
            }

            SettingsListItems.Standard {
                text: i18n.tr("Location")
                anchors { left: parent.left; right: parent.right }

                TextField {
                    id: locationField
                    placeholderText: i18n.tr("Optional")
                    enabled: fieldsColumn.enabled
                }
            }

            SettingsItemTitle {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                text: i18n.tr("Driver")
            }

            ListItems.ValueSelector {
                id: driverSelector
                anchors { left: parent.left; right: parent.right }
                text: i18n.tr("Choose driver")
                values: [
                    i18n.tr("Select printer from database"),
                    i18n.tr("Provide PPD file")
                ]
                enabled: parent.enabled
            }

            SettingsListItems.Standard {
                anchors { left: parent.left; right: parent.right }
                text: i18n.tr("Filter drivers")

                TextField {
                    id: driverFilter
                    onTextChanged: Printers.driverFilter = text
                    enabled: fieldsColumn.enabled
                }
                visible: driverSelector.selectedIndex == 0
                enabled: parent.enabled
            }

            ScrollView {
                anchors { left: parent.left; right: parent.right }
                height: units.gu(30)
                contentItem: driversView
                visible: driverSelector.selectedIndex == 0

                ListView {
                    id: driversView
                    property string selectedDriver
                    property bool loading: true
                    model: Printers.drivers
                    anchors { left: parent.left; right: parent.right }
                    height: units.gu(30)
                    clip: true
                    enabled: fieldsColumn.enabled
                    highlightFollowsCurrentItem: false
                    highlight: Rectangle {
                        z: 0
                        y: driversView.currentItem.y
                        width: driversView.currentItem.width
                        height: driversView.currentItem.height
                        color: theme.palette.selected.background
                    }
                    delegate: ListItem {
                        id: driverItem
                        height: driverLayout.height + (divider.visible ? divider.height : 0)
                        ListItemLayout {
                            id: driverLayout
                            title.text: displayName

                            Icon {
                                name: "ok"
                                width: units.gu(2)
                                height: width
                                SlotsLayout.position: SlotsLayout.Trailing
                                visible: model.name == driversView.selectedDriver

                            }
                        }
                        onClicked: {
                            driversView.selectedDriver = name
                            driversView.currentIndex = index
                        }
                    }

                    ActivityIndicator {
                        anchors.centerIn: parent
                        running: parent.loading
                    }

                    Connections {
                        target: driversView
                        onCountChanged: {
                            target = null;
                            driversView.loading = false;
                        }
                    }
                }
            }

            ListItems.Standard {
                text: i18n.tr("PPD file")
                visible: driverSelector.selectedIndex == 1
                control: TextField {
                    id: printerPpd
                }
                enabled: parent.enabled
                id: pddFileField
            }
        }

        SettingsItemTitle {
            id: remotePrintersTitle
            anchors {
                left: parent.left
                right: parent.right
                top: fieldsColumn.bottom
            }
            text: i18n.tr("Other printers")

            ActivityIndicator {
                id: remotePrintersSearchIndicator
                anchors {
                    right: parent.right
                    rightMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }
                property var target
                Component.onCompleted: target = Printers.remotePrinters
                running: target.searching
            }
        }

        ListView {
            id: remotePrintersList
            contentHeight: contentItem.childrenRect.height
            anchors {
                left: parent.left
                right: parent.right
                top: remotePrintersTitle.bottom
            }
            model: Printers.remotePrinters
            delegate: ListItem {
                height: modelLayout.height + (divider.visible ? divider.height : 0)
                ListItemLayout {
                    id: modelLayout
                    title.text: displayName
                    subtitle.text: info

                    Icon {
                        id: icon
                        width: height
                        height: units.gu(2.5)
                        name: "network-printer-symbolic"
                        SlotsLayout.position: SlotsLayout.First
                    }

                    Button {
                        text: i18n.tr("Add printer")
                        onClicked: {
                            var suggestedPrinterName = (" " + displayName).slice(1);
                            suggestedPrinterName = suggestedPrinterName.replace(/\ /g, "\-");
                            nameField.text = suggestedPrinterName;
                            connection.host = uri;
                            descriptionField.text = info;
                            locationField.text = location;
                            connection.type = type;
                        }
                    }
                }
            }
        }

        Label {
            anchors {
                left: parent.left
                right: parent.right
                top: remotePrintersTitle.bottom
                margins: units.gu(2)
            }
            text: i18n.tr("No other printers found.")
            visible: !remotePrintersSearchIndicator.running && remotePrintersList.count == 0
        }
    }

    Timer {
        id: successTimer
        interval: 2000
        onTriggered: pageStack.removePages(addPrinterPage)
    }
}
