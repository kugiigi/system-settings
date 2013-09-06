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

import GSettings 1.0
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
import Ubuntu.SystemSettings.SecurityPrivacy 1.0
import SystemSettings 1.0

ItemPage {
    title: i18n.tr("Lock security")

    UbuntuSecurityPrivacyPanel {
        id: securityPrivacy
    }

    function methodToIndex(method) {
        switch (method) {
            case UbuntuSecurityPrivacyPanel.Swipe:
                return 0
            case UbuntuSecurityPrivacyPanel.Passcode:
                return 1
            case UbuntuSecurityPrivacyPanel.Passphrase:
                return 2
        }
    }

    function indexToMethod(index) {
        switch (index) {
            case 0:
                return UbuntuSecurityPrivacyPanel.Swipe
            case 1:
                return UbuntuSecurityPrivacyPanel.Passcode
            case 2:
                return UbuntuSecurityPrivacyPanel.Passphrase
        }
    }

    Dialog {
        id: changeSecurityDialog

        property int oldMethod: securityPrivacy.securityType
        property int newMethod: indexToMethod(unlockMethod.selectedIndex)

        function clearInputs() {
            currentInput.text = ""
            newInput.text = ""
            confirmInput.text = ""
        }

        title: {
            if (changeSecurityDialog.newMethod ==
                    changeSecurityDialog.oldMethod) { // Changing existing
                switch (changeSecurityDialog.newMethod) {
                case UbuntuSecurityPrivacyPanel.Passcode:
                    return i18n.tr("Change passcode")
                case UbuntuSecurityPrivacyPanel.Passphrase:
                    return i18n.tr("Change passphrase")
                default: // To stop the runtime complaining
                    return i18n.tr("Change")
                }
            } else {
                switch (changeSecurityDialog.newMethod) {
                case UbuntuSecurityPrivacyPanel.Swipe:
                    return i18n.tr("Switch to swipe")
                case UbuntuSecurityPrivacyPanel.Passcode:
                    return i18n.tr("Switch to passcode")
                case UbuntuSecurityPrivacyPanel.Passphrase:
                    return i18n.tr("Switch to passphrase")
                }
            }
        }

        Label {
            text: {
                switch (changeSecurityDialog.oldMethod) {
                case UbuntuSecurityPrivacyPanel.Passcode:
                    return i18n.tr("Existing passcode")
                case UbuntuSecurityPrivacyPanel.Passphrase:
                    return i18n.tr("Existing passphrase")
                // Shouldn't be reached when visible but still evaluated
                default:
                    return i18n.tr("Existing")
                }
            }

            visible: currentInput.visible
        }

        TextField {
            id: currentInput
            echoMode: TextInput.Password
            inputMethodHints: {
                if (changeSecurityDialog.oldMethod ===
                        UbuntuSecurityPrivacyPanel.Passphrase)
                    return Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData
                else if (changeSecurityDialog.oldMethod ===
                         UbuntuSecurityPrivacyPanel.Passcode)
                    return Qt.ImhNoAutoUppercase |
                           Qt.ImhSensitiveData |
                           Qt.ImhDigitsOnly
                else
                    return Qt.ImhNone
            }
            inputMask: {
                if (changeSecurityDialog.oldMethod ===
                        UbuntuSecurityPrivacyPanel.Passcode)
                    return "9999"
                else
                    return ""
            }
            visible: changeSecurityDialog.oldMethod ===
                        UbuntuSecurityPrivacyPanel.Passphrase ||
                     changeSecurityDialog.oldMethod ===
                         UbuntuSecurityPrivacyPanel.Passcode
        }

        Label {
            text: {
                switch (changeSecurityDialog.newMethod) {
                case UbuntuSecurityPrivacyPanel.Passcode:
                    return i18n.tr("Choose passcode")
                case UbuntuSecurityPrivacyPanel.Passphrase:
                    return i18n.tr("Choose passphrase")
                // Shouldn't be reached when visible but still evaluated
                default:
                    return i18n.tr("Choose")
                }
            }
            visible: newInput.visible
        }

        TextField {
            id: newInput
            echoMode: TextInput.Password
            inputMethodHints: {
                if (changeSecurityDialog.newMethod ===
                        UbuntuSecurityPrivacyPanel.Passphrase)
                    return Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData
                else if (changeSecurityDialog.newMethod ===
                         UbuntuSecurityPrivacyPanel.Passcode)
                    return Qt.ImhNoAutoUppercase |
                           Qt.ImhSensitiveData |
                           Qt.ImhDigitsOnly
                else
                    return Qt.ImhNone
            }
            inputMask: {
                if (changeSecurityDialog.newMethod ===
                        UbuntuSecurityPrivacyPanel.Passcode)
                    return "9999"
                else
                    return ""
            }
            visible: changeSecurityDialog.newMethod ===
                        UbuntuSecurityPrivacyPanel.Passcode ||
                     changeSecurityDialog.newMethod ===
                        UbuntuSecurityPrivacyPanel.Passphrase
        }

        Label {
            text: {
                switch (changeSecurityDialog.newMethod) {
                case UbuntuSecurityPrivacyPanel.Passcode:
                    return i18n.tr("Confirm passcode")
                case UbuntuSecurityPrivacyPanel.Passphrase:
                    return i18n.tr("Conrifm passphrase")
                // Shouldn't be reached when visible but still evaluated
                default:
                    return i18n.tr("Confirm")
                }
            }
            visible: confirmInput.visible
        }

        TextField {
            id: confirmInput
            echoMode: TextInput.Password
            inputMethodHints: {
                if (changeSecurityDialog.newMethod ===
                        UbuntuSecurityPrivacyPanel.Passphrase)
                    return Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData
                else if (changeSecurityDialog.newMethod ===
                         UbuntuSecurityPrivacyPanel.Passcode)
                    return Qt.ImhNoAutoUppercase |
                           Qt.ImhSensitiveData |
                           Qt.ImhDigitsOnly
                else
                    return Qt.ImhNone
            }
            inputMask: {
                if (changeSecurityDialog.newMethod ===
                        UbuntuSecurityPrivacyPanel.Passcode)
                    return "9999"
                else
                    return ""
            }
            visible: changeSecurityDialog.newMethod ===
                        UbuntuSecurityPrivacyPanel.Passcode ||
                     changeSecurityDialog.newMethod ===
                        UbuntuSecurityPrivacyPanel.Passphrase
        }

        Button {
            text: changeSecurityDialog.newMethod ===
                    UbuntuSecurityPrivacyPanel.Swipe ?
                      i18n.tr("Unset") :
                      i18n.tr("Continue")
            enabled: newInput.text == confirmInput.text
            onClicked: {
                PopupUtils.close(changeSecurityDialog)
                //TODO: Check it's correct before updating and do the update
                securityPrivacy.securityType =
                        indexToMethod(unlockMethod.selectedIndex)

                changeSecurityDialog.clearInputs()
            }

        }

        Button {
            text: i18n.tr("Cancel")
            onClicked: {
                PopupUtils.close(changeSecurityDialog)
                unlockMethod.skip = true
                unlockMethod.selectedIndex =
                        methodToIndex(securityPrivacy.securityType)
                changeSecurityDialog.clearInputs()
            }
        }
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right

        ListItem.Standard {
            text: i18n.tr("Unlock the phone using:")
        }

        ListItem.ValueSelector {
            property string swipe: i18n.tr("Swipe (no security)")
            property string passcode: i18n.tr("4-digit passcode")
            property string passphrase: i18n.tr("Passphrase")
            property string swipeAlt: i18n.tr("Swipe (no security)… ")
            property string passcodeAlt: i18n.tr("4-digit passcode…")
            property string passphraseAlt: i18n.tr("Passphrase…")

            property bool skip: true
            property bool firstRun: true

            id: unlockMethod
            values: [
                selectedIndex == 0 ? swipe : swipeAlt,
                selectedIndex == 1 ? passcode : passcodeAlt,
                selectedIndex == 2 ? passphrase : passphraseAlt
            ]
            expanded: true
            onExpandedChanged: expanded = true
            onSelectedIndexChanged: {
                if (securityPrivacy.securityType ===
                        UbuntuSecurityPrivacyPanel.Swipe && firstRun) {
                    changeSecurityDialog.show()
                    firstRun = false
                }

                // Otherwise the dialogs pop up the first time
                if (skip) {
                    skip = false
                    return
                }

                changeSecurityDialog.show()
            }
        }
        Binding {
            target: unlockMethod
            property: "selectedIndex"
            value: methodToIndex(securityPrivacy.securityType)
        }

        ListItem.SingleControl {

            visible: securityPrivacy.securityType !==
                        UbuntuSecurityPrivacyPanel.Swipe

            control: Button {
                property string changePasscode: i18n.tr("Change passcode…")
                property string changePassphrase: i18n.tr("Change passphrase…")

                property bool passcode: securityPrivacy.securityType ===
                                        UbuntuSecurityPrivacyPanel.Passcode

                enabled: parent.visible

                text: passcode ? changePasscode : changePassphrase
                width: parent.width - units.gu(4)

                onClicked: changeSecurityDialog.show()
            }
        }
    }
}