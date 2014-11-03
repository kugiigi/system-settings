/*
 * This file is part of system-settings
 *
 * Copyright (C) 2013 Canonical Ltd.
 *
 * Contact: Iain Lane <iain.lane@canonical.com>
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

import QtQuick 2.0
import QtQuick.Layouts 1.1
import SystemSettings 1.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import MeeGo.QOfono 0.2
import "carriers.js" as CHelper

ItemPage {
    id: root
    title: i18n.tr("Carrier")

    objectName: "chooseCarrierPage"

    property var sim
    property bool scanning: false

    /* Signal that ofono bindings can use to
    trigger an update of the UI */
    signal operatorsChanged ()

    QtObject {
        id: d
        property bool __suppressActivation: false
    }

    onOperatorsChanged: CHelper.operatorsChanged();
    Component.onCompleted: {
        console.warn('Scan start.')
        scanTimer.start();
    }

    Timer {
        id: scanTimer
        interval: 1500
        repeat: false
        running: false
        onTriggered: {
            sim.netReg.scan();
            scanning = true;
            d.__suppressActivation = true;
        }
    }

    Connections {
        target: sim.netReg
        onNetworkOperatorsChanged: operatorsChanged()
        onScanFinished: {
            if (scanning) {
                console.warn('Scan done.')
                scanning = false;
                d.__suppressActivation = false;
            }
        }
        onScanError: {
            scanning = false;
            d.__suppressActivation = false;
            console.warn("onScanError: " + message);
        }
    }

    Component {
        id: netOp
        OfonoNetworkOperator {
            onRegisterComplete: {
                if (error === OfonoNetworkOperator.InProgressError) {
                    console.warn("Register failed, already one in progress.");
                    operatorsChanged()
                } else if (error !== OfonoNetworkOperator.NoError) {
                    console.warn("Register complete:", errorString);
                    console.warn("Falling back to default operator.");
                    sim.netReg.registration();
                    operatorsChanged();
                }
            }
            onNameChanged: operatorsChanged();
            onStatusChanged: operatorsChanged();
        }
    }

    Flickable {
        id: scrollWidget
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: parent.height
        boundsBehavior: (contentHeight > parent.height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds

        ColumnLayout {
            anchors {
                left: parent.left
                right: parent.right
            }
            spacing: 0
            Button {
                text: "FOOBAR"
                onClicked: {
                    console.warn(sim.netReg.mode);
                }
            }
            ListItem.ItemSelector {
                id: chooseCarrier
                objectName: "mode"
                expanded: true
                enabled: sim.netReg.mode !== "auto-only" && !scanning
                // work around unfortunate ui
                opacity: enabled ? 1.0 : 0.5
                text: i18n.tr("Choose carrier:")
                model: [i18n.tr("Automatically")]
                delegate: OptionSelectorDelegate { showDivider: false }
                selectedIndex: sim.netReg.mode === "auto" ? 0 : -1
                onDelegateClicked: sim.netReg.registration()
            }

            ListItem.Standard {
                id: curOpLabel
                enabled: false
                text: i18n.tr("None")
            }

            ListItem.ItemSelector {
                id: carrierSelector
                objectName: "carriers"
                visible: !root.scanning
                expanded: true
                delegate: OptionSelectorDelegate {
                    objectName: "carrier"
                    enabled: carrierSelector.enabled
                    showDivider: false
                    text: modelData.name
                }
                onDelegateClicked: {
                    if (selectedIndex === -1 || d.__suppressActivation) {
                        console.warn('Ignored user request');
                        return;
                    }
                    if (index === selectedIndex) {
                        return;
                    }
                    CHelper.setCurrentOp(model[index].operatorPath);
                }

                Rectangle {
                    id: searchingOverlay
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    opacity: root.scanning ? 1 : 0
                    height: chooseCarrier.itemHeight - units.gu(0.15)
                    color: Theme.palette.normal.background
                    z: 2
                    ActivityIndicator {
                        id: act
                        anchors {
                            left: parent.left
                            margins: units.gu(2)
                            verticalCenter: parent.verticalCenter
                        }
                        running: root.scanning
                    }

                    Label {
                        anchors {
                            left: act.right
                            right: parent.right
                            top: parent.top
                            bottom: parent.bottom
                            leftMargin: units.gu(1)
                        }
                        height: parent.height
                        text: i18n.tr("Searching for carriers…")
                        verticalAlignment: Text.AlignVCenter
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: UbuntuAnimation.SnapDuration
                        }
                    }
                }
            }
        }
    }
}
