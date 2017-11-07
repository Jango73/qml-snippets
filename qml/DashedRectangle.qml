import QtQuick 2.5
import "../../system"

/*!
     \brief A rectangle drawn with dashed lines.
*/

Canvas {
    id: root

    /*!
        This is the color of the borders of the rectangle.
    */
    property color borderColor : Ambiance.item.interactiveElementColor //"#FFFFFF"

    /*!
        This is the width of the borders of the rectangle.
    */
    property real borderWidth: 4

    /*!
        This is the length of a dash.
    */
    property real dashLength: 10

    /*!
        This is the length of the space between two dashes.
    */
    property real dashSpace: 10

    /*!
        Used internally.
    */
    property real stippleLength: (dashLength + dashSpace) > 0 ? (dashLength + dashSpace) : 16

    onBorderColorChanged: root.requestPaint()
    onBorderWidthChanged: root.requestPaint()
    onDashLengthChanged: root.requestPaint()
    onDashSpaceChanged: root.requestPaint()

    onPaint: {
        var context = getContext("2d");
        context.clearRect(0, 0, width, height);
        context.strokeStyle = borderColor;
        context.lineWidth = borderWidth;

        // context.setLineDash([5, 15]); // This is  not supported by Qt

        var p1 = { x: 0, y: 0 }
        var p2 = { x: width, y: 0 }
        var p3 = { x: width, y: height }
        var p4 = { x: 0, y: height }

        drawDashedLine(context, p1, p2);
        drawDashedLine(context, p2, p3);
        drawDashedLine(context, p3, p4);
        drawDashedLine(context, p4, p1);
    }

    function drawDashedLine(context, start, end) {
        var dashLen = stippleLength;
        var dX = end.x - start.x;
        var dY = end.y - start.y;
        var dashes = Math.floor(Math.sqrt(dX * dX + dY * dY) / dashLen);

        if (dashes == 0)
        {
            dashes = 1;
        }

        var dashToLength = dashLength / dashLen
        var spaceToLength = 1 - dashToLength
        var dashX = dX / dashes;
        var dashY = dY / dashes;
        var x1 = start.x;
        var y1 = start.y;

        context.beginPath();
        context.moveTo(x1,y1);

        var q = 0;
        while (q++ < dashes) {
            x1 += dashX * dashToLength;
            y1 += dashY * dashToLength;
            context.lineTo(x1, y1);
            x1 += dashX * spaceToLength;
            y1 += dashY * spaceToLength;
            context.moveTo(x1, y1);

        }
        context.stroke();
    }
 }
