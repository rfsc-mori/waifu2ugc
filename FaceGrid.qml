import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.0

Item {
    property int horizontalCount
    property int verticalCount

    property size faceSize
    property size scaledFaceSize: Qt.size(faceSize.width * width / (faceSize.width * horizontalCount),
                                          faceSize.height * height / (faceSize.height * verticalCount))
    property real lineWidth: 1
    property string strokeStyle: "black"

    onScaledFaceSizeChanged: Qt.callLater(gridCanvas.requestPaint)

    Canvas {
        id: gridCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")

            if (horizontalCount > 1 || verticalCount > 1)
            {
                ctx.lineWidth = lineWidth
                ctx.strokeStyle = strokeStyle

                ctx.beginPath()

                for (var h = 1; h < horizontalCount; ++h)
                {
                    ctx.moveTo(scaledFaceSize.width * h, 0)
                    ctx.lineTo(scaledFaceSize.width * h, height)
                }

                for (var v = 1; v < verticalCount; ++v)
                {
                    ctx.moveTo(0, scaledFaceSize.height * v)
                    ctx.lineTo(width, scaledFaceSize.height * v)
                }

                ctx.closePath()
                ctx.stroke()
            }
            else
            {
                ctx.reset()
            }
        }
    }
}
