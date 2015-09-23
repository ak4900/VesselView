import QtQuick 1.0

Rectangle  {

    id: welcomeRectangle
    width: 500
    height: 300
    SystemPalette { id: activePalette; colorGroup: SystemPalette.Active }
    FontLoader { source: ":/Gutenberg.ttf" }
    color: activePalette.base
    property variant welcomeListModel: WelcomeListModel{}
    property string selectedModule: ""
    property variant selectedFiles: []
    property int selectedLayout: -1
    property int generalMargin: 5
    property int generalSpacing: 2*generalMargin
    property real gradientStart: 0.8
    property real gradientEnd: 1.0
    property int currentIndexWelcomeListView : -1
    property real welcomeListWidth: Math.floor((welcomeRectangle.width - 2*generalMargin) / 4)
    property string aboutSource: ":/Icons/Medium/KitwareLogo.svg"
    property string aboutText: "
 <html>
 <div text-align=\"left\">
 VesselView is a demonstration application
 from <a href=\"http://www.kitware.com/\">Kitware, Inc.</a> for the 
 segmentation, registration, and analysis of tubes (e.g., blood vessels) in
 3D images (e.g., MRI, CT, and Ultrasound).
 </div>
 <br><br>
 <center>
 <table>
   <tr> 
     <td>
       <img src=\":WelcomeAbout.png\" width=250>
     </td>
     <td>
       <br><br>
       <center>
       For more information, visit <br>
       <a href=\"http://public.kitware.com/Wiki/TubeTK/About\">http://public.kitware.com/Wiki/TubeTK/About</a>
       </center>
     </td>
   </tr>
 </table>
 </center>
 <br><br>
 <div text-align=\"left\">
 VesselView is free for academic and commercial use.  It is based on
 <a href=\"http://www.tubetk.org/\">TubeTK</a> and
 <a href=\"http://www.slicer.org/\">3D Slicer</a>.  It is provided as-is and
 without expressed or implied warranty of suitability for any task.
 </div>
 </html> "


    function elementHeightFunction(height, numberOfElements, spacing)
    {
        var numberOfFullElements = Math.floor(numberOfElements)
        var heightWithoutSpaces = height - (numberOfFullElements-1) * spacing
        return Math.floor(heightWithoutSpaces / numberOfElements)
    }
    property int elementHeight : elementHeightFunction(
        welcomeRectangle.height - 2*generalMargin,
        4.5 + 1, //+1 for the about rectangle
        generalSpacing
    )

    Rectangle {
        id: aboutRectangle
        visible: true
        anchors{
            left: welcomeListView.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            margins: generalMargin
        }

        color: activePalette.base
        border.color: activePalette.base
        radius: generalMargin

        Image {
            id: aboutRectangleImage
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: parent.top
            anchors.topMargin: Math.floor( aboutRectangle.height / 6)
            height: Math.floor( aboutRectangle.height / 4)
            fillMode: Image.PreserveAspectFit
            source: aboutSource
        }


        Text{
            id: aboutRectangleText
            anchors.right: parent.right
            anchors.rightMargin: Math.floor( parent.width * 0.125 )
            anchors.left: parent.left
            anchors.leftMargin: Math.floor( parent.width * 0.125 )
            anchors.top: aboutRectangleImage.bottom
            anchors.topMargin: Math.floor( aboutRectangleImage.height / 2 )
            height:Math.floor( aboutRectangle.height / 2)
            wrapMode: Text.WordWrap
            font.pointSize: 16
            color: activePalette.text
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignLeft
            text: aboutText
            onLinkActivated: Qt.openUrlExternally(link)
            clip: true
        }
    }

    VerticalListViewWithButtons {
        id: welcomeListView

        buttonRadius: generalMargin
        buttonHeight: Math.floor(elementHeight / 4) + 3 * generalSpacing

        spacing: generalSpacing

        anchors.left: parent.left
        anchors.leftMargin: generalSpacing
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: welcomeListWidth

        model: welcomeListModel
        delegate: WelcomeListDelegate {}

        onCurrentItemChanged: {
			if(currentIndex == 0){
                selectedModule = ""
                selectedLayout = -1
                aboutRectangle.visible = true
                descriptionRectangle.visible = false
                openButton.visible = false
                horizontalListWithButtons.visible = false;
                recentlyLoadedFilesModel.fileTypes = ""
                selectedFiles = []
            }
            else if (currentIndex != -1) {
                selectedModule = model.get(currentIndex).module
                selectedLayout = model.get(currentIndex).layout
                aboutRectangle.visible = false
                descriptionRectangle.visible = true
                descriptionRectangleText.text =
                  model.get(currentIndex).description
               // descriptionRectangleImage.source =
               //   model.get(currentIndex).imageSource
                openButton.visible = true
                recentlyLoadedFilesModel.fileTypes =
                  model.get(currentIndex).fileTypes
                selectedFiles = []
				horizontalListWithButtons.visible = true
                subTasksListView.currentIndex = 0
				currentIndexWelcomeListView = currentIndex
            }
        }
    }

    Rectangle{
        id: horizontalListWithButtons
        visible: false
        anchors{
            left: welcomeListView.right
            right: parent.right
            top: parent.top
            leftMargin: generalMargin
            rightMargin: generalMargin
            topMargin: welcomeListView.buttonHeight
        }
        color: activePalette.base
        height: elementHeight + generalSpacing//aboutRectangle.height

        ListView {
               id: subTasksListView
               spacing: generalSpacing
               anchors.fill:parent
               currentIndex: -1
               clip:true
               snapMode: ListView.SnapToItem
               boundsBehavior: Flickable.StopAtBounds

               orientation: ListView.Horizontal
               model: welcomeListModel.get(currentIndexWelcomeListView).subTasks
               delegate: WelcomeListDelegate {}
               onCurrentItemChanged: {
                   if (currentIndex != -1) {
                       selectedModule = model.get(currentIndex).module
                       selectedLayout = model.get(currentIndex).layout
                       aboutRectangle.visible = false
                       descriptionRectangle.visible = true
                       descriptionRectangleText.text =
                         model.get(currentIndex).description
                    //   descriptionRectangleImage.source =
                     //    model.get(currentIndex).imageSource
                       openButton.visible = true
                       recentlyLoadedFilesModel.fileTypes =
                         model.get(currentIndex).fileTypes
                       selectedFiles = []
                   }
               }
           }
    }

    Rectangle {
        id: descriptionRectangle
        color: activePalette.base
        anchors.rightMargin: generalMargin
        anchors.right: parent.right
        anchors.left: welcomeListView.right
        anchors.leftMargin: generalMargin
        anchors.top : horizontalListWithButtons.bottom
        anchors.bottom: openButton.top
        height: welcomeListView.height
		visible: false

     /*   Image {
            id: descriptionRectangleImage
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: parent.top
            anchors.topMargin: Math.floor( descriptionRectangle.height / 8 )
            height: Math.floor( descriptionRectangle.height / 4)
            fillMode: Image.PreserveAspectFit
            source: aboutSource
        }
*/

        Text{
            id: descriptionRectangleText
            anchors.right: parent.right
            anchors.rightMargin: Math.floor( parent.width * 0.125 )
            anchors.left: parent.left
            anchors.leftMargin: Math.floor( parent.width * 0.125 )
            anchors.top: parent.top
            anchors.topMargin: Math.floor( elementHeight / 2 )
            height:Math.floor( parent.height/2)
            wrapMode: Text.WordWrap
            font.pointSize: 16
            color: activePalette.text
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignLeft
            text: aboutText
            onLinkActivated: Qt.openUrlExternally(link)
            clip: true
        } 
    }

    Rectangle{
        id:recentFiles
        anchors.right: parent.right
        anchors.rightMargin: Math.floor( parent.width * 0.125 )
        anchors.left: welcomeListView.right
        anchors.leftMargin: Math.floor( parent.width * 0.125 )
        anchors.top:descriptionRectangle.bottom
        anchors.topMargin: generalMargin
        color:activePalette.base
        height:recentFilesTextBox.paintedHeight
        Text {
            id: recentFilesTextBox
            anchors.fill: parent
            height: recentFilesTextBox.paintedHeight
            text: "Recent files:"
            color: activePalette.text
            font.pixelSize: 14
        }
        states:[
            State{
                name: "visible"
                when: recentFiles.visible == true
                PropertyChanges{
                    target:descriptionRectangle
                    anchors.bottomMargin: Math.floor(welcomeListView.height/8 )
                }
            }
        ]
    }

    Binding {
         target: recentFilesTextBox
         property: "visible"
         value: recentlyLoadedFilesModel.hasAtLeastOneEntry()
     }

    ListView {
        id: recentFilesView
        spacing: generalSpacing
        anchors.top: recentFiles.bottom
        anchors.topMargin: generalMargin
        anchors.bottom: openButton.top
        anchors.bottomMargin: generalMargin
        anchors.right: welcomeRectangle.right
        anchors.rightMargin: Math.floor( parent.width * 0.125 )
        anchors.left: welcomeListView.right
        anchors.leftMargin: Math.floor( parent.width * 0.125 )
        clip:true
        snapMode: ListView.SnapToItem
        boundsBehavior: Flickable.StopAtBounds

        model: recentlyLoadedFilesModel

        delegate: Rectangle{
            id: recentFilesDelegateItem
            anchors.right: parent.right
            anchors.rightMargin: 5 * generalMargin
            anchors.left: parent.left
            anchors.leftMargin: 5 * generalMargin
            height: 20

            color: activePalette.button
            border.color: activePalette.dark
            radius: generalMargin

            Text {
                id: recentFilesDelegateItemTextIcon
                anchors.left: parent.left
                anchors.leftMargin: generalMargin
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                text: "\uf15b" // fa-file
                color: activePalette.text
                font.pixelSize: 14
                font.family: "FontAwesome"
                verticalAlignment: Text.AlignVCenter
            }
            Text {
                id: recentFilesDelegateItemText
                anchors.left: recentFilesDelegateItemTextIcon.right
                anchors.leftMargin: generalMargin
                anchors.right: parent.right
                anchors.rightMargin: generalMargin
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                text: filename
                color: activePalette.text
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideLeft
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    recentFilesView.currentIndex = index

                    var selected =
                      (recentFilesDelegateItem.color == activePalette.button)
                    var fileToLoad =
                      recentlyLoadedFilesModel.filename(
                      recentFilesView.currentIndex)

                    if (selected) {
                        recentFilesDelegateItem.color = activePalette.dark

                        welcomeScreen.addUniqueFileToOpenOnLoad(fileToLoad)
                    }
                    else {
                        recentFilesDelegateItem.color = activePalette.button

                        welcomeScreen.removeOneFileToOpenOnLoad(fileToLoad)
                    }
                }
                onDoubleClicked: {
                    recentFilesView.currentIndex = index
                    recentFilesDelegateItem.color = activePalette.dark
                    var fileToLoad = recentlyLoadedFilesModel.filename(
                      recentFilesView.currentIndex)
                    welcomeScreen.addUniqueFileToOpenOnLoad(fileToLoad)
                    welcomeScreen.loadModule(selectedModule, selectedLayout)
                }
            }
        }
        focus: true
        currentIndex: -1
    }

    Rectangle {
        id: openButton
        visible: false

        anchors.right: welcomeRectangle.right
        anchors.left: welcomeListView.right

        anchors.bottom: parent.bottom
        anchors.bottomMargin: Math.floor(parent.height / 20)
        height: Math.floor(parent.height / 20)
        color: activePalette.base


        Rectangle {
            id: loadButtonButton
            anchors.fill: openButton
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.leftMargin: Math.floor( parent.width / 4 )-generalMargin
            anchors.rightMargin: Math.floor( parent.width / 2 )+generalMargin
            radius: generalMargin
            color: "olivedrab"            
            Text {
                id: loadButtonText
                anchors.fill: loadButtonButton
                text: "Load New Data"
                font.pointSize: 20
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            MouseArea {
                anchors.fill: loadButtonButton
                onPressed: {
                  parent.color = activePalette.dark
                }
                onExited: {
                  parent.color = "olivedrab"
                }
                onReleased: {
                  parent.color = "olivedrab"
                }
                onClicked: {
                  parent.color = "olivedrab"
                  welcomeScreen.loadNewData()
                  welcomeScreen.loadModule(selectedModule, selectedLayout)
                }
            }
        }

        Rectangle {
            id: openButtonButton
            anchors.fill: openButton
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.leftMargin: Math.floor( parent.width / 2 )
            anchors.rightMargin: Math.floor( parent.width / 4 )
            radius: generalMargin
            color: "olivedrab"
            Text {
                id: openButtonText
                anchors.fill: openButtonButton
                text: "Open"
                font.pointSize: 20
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            MouseArea {
                anchors.fill: openButtonButton
                onPressed: {
                  parent.color = activePalette.dark
                }
                onExited: {
                  parent.color = "olivedrab"
                }
                onReleased: {
                  parent.color = "olivedrab"
                }
                onClicked: {
                  parent.color = "olivedrab"
                  welcomeScreen.loadModule(selectedModule, selectedLayout)
                }
            }
        }
    }

}
