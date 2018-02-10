
// All units expressed in grid cells
//
// gridWidth : number of horizontal cells
// gridHeight : number of vertical cells
//
// rectList : existing rectangles in grid
// Ex: { "id" = 1, "x" = 1, "y" = 3, "width = 1", "height = 1" }
//
// sourceRect: in case of swap action, origin rectangle of targetRect (where it's coming from)
// Ex: { "x" = 1, "y" = 3, "width = 1", "height = 1" }
//
// targetRect : target rectangle in grid (where the user wants to drop the widget)
// Ex: { "x" = 1, "y" = 3, "width = 1", "height = 1" }
//
// allowBlockMoves : if true, neighbors of targetRect can move with it, where possible
//
// Out : all input rects as { "id" = 1, "deltaX" = 1, "deltaY" = 2 }, { "id" = 1, "deltaX" = 0, "deltaY" = 0 }, ...
//
// Notes:
// Neighbor is used to identify a rect that moves along with targetRect

function widgetGridSolver(gridWidth, gridHeight, rectList, sourceRect, targetRect, allowBlockMoves)
{
    var i, j;
    var addRect;

    // Setup the orignal movement list
    var returnValue = [];
    var savedTargetRect = cloneRect(targetRect);
    var savedFollowingRects = [];
    var movedFollowingRects = [];

    var rectLists = [];
    var solutions = [];
    var deltaSums = [];

    if (allowBlockMoves)
    {
        // Find all neighbors of sourceRect
        var deltaSourceTarget = { x: targetRect.x - sourceRect.x, y: targetRect.y - sourceRect.y };

        // Iterate over each input rect
        for (i = 0; i < rectList.length; i++)
        {
            // If current input rect intersects targetRect
            if (rectIntersection(targetRect, rectList[i]))
            {
                // Get largest rect between targetRect and the current input rect
                var largeRect = largestRect(targetRect, rectList[i]);

                // If the largest rect is the current input rect
                if (largeRect === rectList[i])
                {
                    // console.log("Found largest rect", largeRect.id);

                    for (j = 0; j < rectList.length; j++)
                    {
                        if (rectList[j] !== largeRect)
                        {
                            var testRect = cloneRect(rectList[j]);

                            testRect.x += deltaSourceTarget.x;
                            testRect.y += deltaSourceTarget.y;

                            if (rectIntersection(testRect, largeRect) && inGridBounds(gridWidth, gridHeight, testRect))
                            {
                                // console.log("Found intersection with largest rect: (", rectList[j].id, ") ", rectList[j].x, rectList[j].y);

                                // Remove this rect from the given rectangle list and assume it has moved along with sourceRect
                                var rect = rectList.splice(j, 1)[0];

                                savedFollowingRects.push(cloneRect(rect));
                                movedFollowingRects.push(testRect);
                                j--;

                                // console.log("Removed rect: (", rect.id, ") ", rect.x, rect.y);

                                // Create a union between target rect and this rect
                                targetRect = unionRects(targetRect, testRect);
                            }
                        }
                    }
                }

                break;
            }
        }
    }

    // Initialize solution results to the given rectangle list (without moving neighbors if allowBlockMoves is true)
    rectLists.push(cloneRectList(rectList));
    rectLists.push(cloneRectList(rectList));
    rectLists.push(cloneRectList(rectList));
    rectLists.push(cloneRectList(rectList));
    rectLists.push(cloneRectList(rectList));

    // console.log("Source rect = (", sourceRect.id, ")", sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height);
    // console.log("Target rect = (", targetRect.id, ")", targetRect.x, targetRect.y, targetRect.width, targetRect.height);

    // Find a solution by moving obstacles up, right, down and left
    solutions.push(findSolution(gridWidth, gridHeight, rectLists[0], sourceRect, targetRect, 0));
    solutions.push(findSolution(gridWidth, gridHeight, rectLists[1], sourceRect, targetRect, 1));
    solutions.push(findSolution(gridWidth, gridHeight, rectLists[2], sourceRect, targetRect, 2));
    solutions.push(findSolution(gridWidth, gridHeight, rectLists[3], sourceRect, targetRect, 3));

    // log("Results: " + solution0 + ", " + solution1 + ", " + solution2 + ", " + solution3);

    if (allowBlockMoves)
    {
        // Put back removed neighbors in all rectangle lists
        for (j = 0; j < savedFollowingRects.length; j++)
        {
            addRect = cloneRect(savedFollowingRects[j]);

            // console.log("Add rect (", addRect.id, ")", addRect.x, addRect.y, addRect.width, addRect.height);

            rectList.push(addRect);
        }

        for (i = 0; i < rectLists.length; i++)
        {
            for (j = 0; j < movedFollowingRects.length; j++)
            {
                addRect = cloneRect(movedFollowingRects[j]);

                // console.log("Add rect (", addRect.id, ")", addRect.x, addRect.y, addRect.width, addRect.height);

                rectLists[i].push(addRect);
            }
        }
    }

    // Restore original target rect
    targetRect = savedTargetRect;

    // Find a solution by swapping rects
    solutions.push(findSolution(gridWidth, gridHeight, rectLists[4], sourceRect, targetRect, 4));

    // Check if we have at least one valid solution
    var oneSolutionOK = false;

    for (i = 0; i < solutions.length; i++)
    {
        if (solutions[i] === true)
        {
            oneSolutionOK = true;
            break;
        }
    }

    // If we have at least one solution
    if (oneSolutionOK)
    {
        // Compute sums of movements for all solutions
        for (i = 0; i < solutions.length; i++)
        {
            rectLists[i] = rectListAsDeltas(rectList, rectLists[i]);
            deltaSums.push(sumDeltas(rectLists[i]));
        }

        // If the swap solution is ok, return it
        if (solutions[solutions.length - 1])
        {
            returnValue = rectLists[solutions.length - 1];
        }
        else
        {
            // Find the best solution (the one that makes the least moves)
            for (i = 0; i < solutions.length; i++)
            {
                if (solutions[i] === true)
                {
                    var bestSolution = true;

                    // Compare this solution will all others
                    for (j = i + 1; j < solutions.length; j++)
                    {
                        if (solutions[j] === true)
                        {
                            if (deltaSums[i] > deltaSums[j])
                            {
                                bestSolution = false;
                                break;
                            }
                        }
                    }

                    // If this solution is the best, return it
                    if (bestSolution)
                    {
                        returnValue = rectLists[i];
                    }
                }
            }
        }
    }

    return returnValue;
}

// gridWidth : number of horizontal cells
// gridHeight: number of vertical cells
// rectList: rectangles that can be pushed
// targetRect: rectangle that we want to make room for
// direction: 0 = up, 1 = right, 2 = down, 3 = left, 4 = swap

function findSolution(gridWidth, gridHeight, rectList, sourceRect, targetRect, direction)
{
    var index;

    /*
    log(
                "findSolution(gridWidth: " + gridWidth +
                ", gridHeight: " + gridHeight +
                ", rectList.length: " + rectList.length +
                ", direction: " + direction
                );
                */

    // If requested space is empty, return
    if (rectEmpty(gridWidth, gridHeight, rectList, targetRect))
    {
        // log("findSolution: target rect space is empty : return true");
        return true;
    }

    // We want a swap
    if (direction === 4)
    {
        for (index = 0; index < rectList.length; index++)
        {
            // Test if rectList[index] intersects our new rect
            if (rectIntersection(targetRect, rectList[index]))
            {
                // Check if rectList[index] is same size as targetRect
                if (rectList[index].width === targetRect.width && rectList[index].height === targetRect.height)
                {
                    rectList[index].x = sourceRect.x;
                    rectList[index].y = sourceRect.y;

                    if (
                            inGridBounds(gridWidth, gridHeight, rectList[index]) &&
                            rectIntersection(targetRect, rectList[index]) === false &&
                            rectCrossesAnyOtherRect(rectList, rectList[index]) === false
                            )
                    {
                        // log("findSolution: swap ok, returning true");

                        return true;
                    }
                }
            }
        }

        return false;
    }
    // We want a move
    else
    {
        var iterations = 0;

        while (iterations < 20)
        {
            // Find blocking rects

            for (index = 0; index < rectList.length; index++)
            {
                // Test if rectList[index] intersects the target rect

                if (rectIntersection(targetRect, rectList[index]))
                {
                    // log("findSolution: Found blocking rect: " + rectList[index].id);

                    if (makeRoom(gridWidth, gridHeight, rectList, index, direction) === false)
                    {
                        // log("findSolution: makeRoom returned false, returning false");
                        return false;
                    }
                }
            }

            if (rectEmpty(gridWidth, gridHeight, rectList, targetRect))
            {
                // log("findSolution: targetRect space is empty : break loop");
                break;
            }

            iterations++;

            // log("iterations = " + iterations);
        }
    }

    return true;
}

// gridWidth : number of horizontal cells
// gridHeight: number of vertical cells
// rectList: rects that can be moved around
// rectIndex: processed rect index
// direction : 0 = up, 1 = right, 2 = down, 3 = left

function makeRoom(gridWidth, gridHeight, rectList, rectIndex, direction)
{
    var index;

    /*
    log("makeRoom(gridWidth: " + gridWidth +
        ", gridHeight: " + gridHeight +
        ", rectList.length: " + rectList.length +
        ", direction: " + direction +
        ", id: " + rectList[rectIndex].id
        );
        */

    // Move target rect

    switch (direction)
    {
    case 0 : rectList[rectIndex].y -= 1; break;
    case 1 : rectList[rectIndex].x += 1; break;
    case 2 : rectList[rectIndex].y += 1; break;
    case 3 : rectList[rectIndex].x -= 1; break;
    }

    /*
    log("makeRoom: target rect: "
        + "id: " + rectList[rectIndex].id
        + ", x: " + rectList[rectIndex].x
        + ", y: " + rectList[rectIndex].y
        + ", w: " + rectList[rectIndex].width
        + ", h: " + rectList[rectIndex].height
        + "]");
        */

    // Check if new rect space is free

    if (inGridBounds(gridWidth, gridHeight, rectList[rectIndex]) === false)
    {
        // log("makeRoom: target rect not in grid bounds : return false");

        return false;

    }
    else
    {
        // Find blocking rects

        for (index = 0; index < rectList.length; index++)
        {
            if (rectList[index].id !== rectList[rectIndex].id)
            {
                // log("makeRoom: Testing rect id: " + rectList[index].id);

                // Test if rectList[index] intersects our target rect

                if (rectIntersection(rectList[index], rectList[rectIndex]))
                {
                    // log("makeRoom: Found blocking rect: " + rectList[index].id);

                    if (makeRoom(gridWidth, gridHeight, rectList, index, direction) === false) return false;
                }
            }
        }
    }

    return true;
}

function tryToFitRect(gridWidth, gridHeight, rectList, targetRect)
{
    var fitRect = { x: -1, y: -1, width: targetRect.width, height: targetRect.height };

    if (rectEmpty(gridWidth, gridHeight, rectList, targetRect))
    {
        fitRect.x = targetRect.x
        fitRect.y = targetRect.y
    }
    else
    {
        for (var y = -gridHeight; y < gridHeight; y++)
        {
            for (var x = -gridWidth; x < gridWidth; x++)
            {
                var testRect = { x: targetRect.x + x, y: targetRect.y + y, width: targetRect.width, height: targetRect.height };

                if (
                        rectCrossesAnyOtherRect(rectList, testRect) === false &&
                        inGridBounds(gridWidth, gridHeight, testRect)
                )
                {
                    fitRect.x = testRect.x;
                    fitRect.y = testRect.y;
                }
            }
        }
    }

    return fitRect;
}

//-------------------------------------------------------------------------------------------------
// Utility functions

function findFreeSpace(gridWidth, gridHeight, rectList, targetRect)
{
    var rect = cloneRect(targetRect);

    for (var y = 0; y < gridHeight; y++)
    {
        for (var x = 0; x < gridWidth; x++)
        {
            rect.x = x;
            rect.y = y;

            if (rectEmpty(gridWidth, gridHeight, rectList, rect))
            {
                return { x: x, y: y };
            }
        }
    }

    return { x: -1, y: -1 };
}

function largestRect(rect1, rect2)
{
    if (rect1.width * rect1.height > rect2.width * rect2.height) return rect1;
    return rect2;
}

function inGridBounds(gridWidth, gridHeight, rect)
{
    if (rect.x < 0) return false;
    if (rect.y < 0) return false;
    if (rect.x + rect.width > gridWidth) return false;
    if (rect.y + rect.height > gridHeight) return false;

    return true;
}

function rectEmpty(gridWidth, gridHeight, rectList, rect)
{
    if (rect.x + rect.width > gridWidth) return false;
    if (rect.y + rect.height > gridHeight) return false;

    for (var index = 0; index < rectList.length; index++)
    {
        if (rectIntersection(rectList[index], rect))
        {
            return false;
        }
    }

    return true;
}

function rectCrossesAnyOtherRect(rectList, rect)
{
    for (var i = 0; i < rectList.length; i++)
    {
        if (rectList[i].id !== rect.id)
        {
            if (rectIntersection(rectList[i], rect))
            {
                return true;
            }
        }
    }

    return false;
}

function cellEmpy(rectList, x, y)
{
    for (var index = 0; index < rectList.length; index++)
    {
        if (
                rectList[index].x <= x
                && rectList[index].y <= y
                && (rectList[index].x + rectList[index].width) > x
                && (rectList[index].y + rectList[index].height) > y
                )
        {
            return false;
        }
    }

    return true;
}

function rectIntersection(r1, r2)
{
    return !(r1.x + r1.width <= r2.x || r1.y + r1.height <= r2.y || r1.x >= r2.x + r2.width || r1.y >= r2.y + r2.height);
}

function unionRects(r1, r2)
{
    var r1x1 = r1.x;
    var r1y1 = r1.y;
    var r1x2 = r1.x + r1.width;
    var r1y2 = r1.y + r1.height;

    var r2x1 = r2.x;
    var r2y1 = r2.y;
    var r2x2 = r2.x + r2.width;
    var r2y2 = r2.y + r2.height;

    var fx1 = r1x1; if (r2x1 < fx1) fx1 = r2x1;
    var fy1 = r1y1; if (r2y1 < fy1) fy1 = r2y1;
    var fx2 = r1x2; if (r2x2 > fx2) fx2 = r2x2;
    var fy2 = r1y2; if (r2y2 > fy2) fy2 = r2y2;

    return { id: r1.id, x: fx1, y: fy1, width: fx2 - fx1, height: fy2 - fy1 };
}

function cloneRectList(rectList)
{
    var returnValue = [];

    for (var index = 0; index < rectList.length; index++)
    {
        // returnValue.push({id: rectList[index].id, x: rectList[index].x, y: rectList[index].y, width: rectList[index].width, height: rectList[index].height});
        returnValue.push(cloneRect(rectList[index]));
    }

    return returnValue;
}

function cloneRect(rect)
{
    return { id: rect.id, x: rect.x, y: rect.y, width: rect.width, height: rect.height }
}

function rectListAsDeltas(rectList, solution)
{
    var returnValue = [];

    for (var r = 0; r < rectList.length; r++)
    {
        for (var s = 0; s < solution.length; s++)
        {
            if (rectList[r].id === solution[s].id)
            {
                returnValue.push({id: solution[s].id, deltaX: solution[s].x - rectList[r].x, deltaY: solution[s].y - rectList[r].y});
                break;
            }
        }
    }

    return returnValue;
}

function sumDeltas(rectList)
{
    var result = 0;

    for (var index = 0; index < rectList.length; index++)
    {
        result += rectList[index].deltaX;
        result += rectList[index].deltaY;
    }

    return result;
}

function log(text)
{
    // document.getElementById("log").innerHTML += text + "<br>";
    // console.log(text);
}

//-------------------------------------------------------------------------------------------------
// Test functions

// Uncomment code below to test in https://jsfiddle.net/
// Use HTML code below in HTML window
// <div id="before" style="font-family:courier"></div>
// <div id="after" style="font-family:courier"></div>
// <p id="log"></p>

/*
testWidgetGridSolver();

function testWidgetGridSolver()
{
    var testRectList = [];
    var testTargetRect = [];
    var rect;
    var index, index2;
    var text;
    var t0, t1;

    var gridWidth = 10;
    var gridHeight = 4;

    rect = [];
    rect.id = 1;
    rect.x = 0;
    rect.y = 0;
    rect.width = 2;
    rect.height = 1;
    testRectList.push(rect);

    rect = [];
    rect.id = 2;
    rect.x = 2;
    rect.y = 0;
    rect.width = 2;
    rect.height = 1;
    testRectList.push(rect);

    rect = [];
    rect.id = 3;
    rect.x = 6;
    rect.y = 0;
    rect.width = 1;
    rect.height = 1;
    testRectList.push(rect);

    rect = [];
    rect.id = 4;
    rect.x = 0;
    rect.y = 1;
    rect.width = 2;
    rect.height = 2;
    testRectList.push(rect);

    testTargetRect.x = 0;
    testTargetRect.y = 0;
    testTargetRect.width = 2;
    testTargetRect.height = 1;

    for (index = 0; index < testRectList.length; index++)
    {
        text = "Id: " + testRectList[index].id
                + ", x: " + testRectList[index].x
                + ", y: " + testRectList[index].y
                + ", w: " + testRectList[index].width
                + ", h: " + testRectList[index].height;

        log(text);
    }

    fillGrid(gridWidth, gridHeight, testRectList, "before");

    t0 = performance.now();

    var testResultRects1 = widgetGridSolver(gridWidth, gridHeight, testRectList, testTargetRect);

    t1 = performance.now();
    log("Call to widgetGridSolver took " + (t1 - t0) + " milliseconds.")

    for (index = 0; index < testResultRects1.length; index++)
    {
        text = "Id: " + testResultRects1[index].id + ", deltaX: " + testResultRects1[index].deltaX + ", deltaY: " + testResultRects1[index].deltaY;
        log(text);
    }

    for (index = 0; index < testRectList.length; index++)
    {
        for (index2 = 0; index2 < testResultRects1.length; index2++)
        {
            if (testRectList[index].id === testResultRects1[index2].id)
            {
                testRectList[index].x += testResultRects1[index2].deltaX;
                testRectList[index].y += testResultRects1[index2].deltaY;
                break;
            }
        }
    }

    testTargetRect.x = 0;
    testTargetRect.y = 1;
    testTargetRect.width = 2;
    testTargetRect.height = 2;

    t0 = performance.now();

    var testResultRects2 = widgetGridSolver(gridWidth, gridHeight, testRectList, testTargetRect);

    t1 = performance.now();
    log("Call to widgetGridSolver took " + (t1 - t0) + " milliseconds.")

    for (index = 0; index < testRectList.length; index++)
    {
        for (index2 = 0; index2 < testResultRects2.length; index2++)
        {
            if (testRectList[index].id === testResultRects2[index2].id)
            {
                testRectList[index].x += testResultRects2[index2].deltaX;
                testRectList[index].y += testResultRects2[index2].deltaY;
                break;
            }
        }
    }

    fillGrid(gridWidth, gridHeight, testRectList, "after");
}

function fillGrid(gridWidth, gridHeight, rectList, id)
{
    var text = "";

    for (var y = 0; y < gridHeight; y++)
    {
        for (var x = 0; x < gridWidth; x++)
        {
            var empty = cellEmpy(rectList, x, y);

            if (empty)
                text += ".";
            else
                text += "*";
        }

        text += "<br>";
    }

    text += "<br>";

    document.getElementById(id).innerHTML = text;
}
*/
