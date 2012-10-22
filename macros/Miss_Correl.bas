 Attribute VB_Name = "Miss_Correl"
'
'       This module takes a table of data where the columns reprersent different variables (measures)                                                                       Var1     Var2     Var3
'           and the rows the different instances (e.g. countries, subjects, etc) and creates a Pearson's correlation matrix (R^2) from it.            Aus        6.5     12.5   #N/A
'                                                                                                                                                                                                                       Ger         8.9     12.7    0.56
'       The user specifies the data set by selecting it.  There should be Variable labels in the first row of the selection                                   Fra  Delayed     13.6    0.43
'           and subject identifiers/names in the first column.
'
'       The correlation matrix will be created on a new work sheet.  There will be a button on that sheet to allow graphing of
'           any pair of variables
'
'       The code is designed to ignore missing data values (i.e. any value not recognised as numeric).
'
'

Public rCorn As Integer
Public cCorn As Integer

Public Sub Correl()
'  This version is for backward compatibility for old calls to "Correl"  - it defaults output to the sheet "Shout".  If there is an existing sheet of that name it is overwritten.
    CorrelSh ("Shout")
End Sub
Public Sub CorrelAsk()
    ShtName = InputBox("Please give a sheet name for the output" & Chr(13) & "WARNING - If a sheet of this name already exists - it will be DELETED!", "Sheet Name", "Shout")
    CorrelSh (ShtName)
End Sub
Public Sub CorrelSh(ShtName As String)
'  Does a correlation matrix for the selected data and place the output matrix on the sheet ShtName
'
'
Dim dArr As Variant
Dim rArr() As Single, tArr() As Single
Dim SX1 As Double, SX2 As Double, SQX1 As Double, SQX2 As Double
Dim Sx1X2 As Double, Sn As Long
Dim rOut As Range
Dim nShOut As String

rCorn = 10: cCorn = 4        '   These are the top left corner of the correlation matrix on the output sheet
nShOut = ShtName
    
    If TypeName(Selection) <> "Range" Then
        MsgBox "You need to select the data first - top left cell should have labels for rows and columns (only one for each)"
        Exit Sub
    End If
    Application.ScreenUpdating = False
    
    rtop = Selection.Cells(1, 1).Row            '  Mark the top left corner of the raw data matrix - rTop, cTop
    ctop = Selection.Cells(1, 1).Column
    datasheet = ActiveSheet.Name
    
    dArr = Selection.Value                           '  This is the data array - includes left and top labels
    rc = Selection.Rows.Count - 1               '  Note:  Reduced by 1 as top row has var labels
    cc = Selection.Columns.Count - 1         '  Note:  Reduced by one as left col has the item labels
    ReDim rArr(1 To cc, 1 To cc)
    ReDim tArr(1 To cc, 1 To cc)
    c1 = 0
        
    For iV1 = LBound(dArr, 2) + 1 To UBound(dArr, 2) - 1    'Calc by pairs of columns (ie variables or measures)
    c1 = c1 + 1: c2 = c1
    For iV2 = iV1 + 1 To UBound(dArr, 2)
        c2 = c2 + 1
        SX1 = 0: SX2 = 0: SQX1 = 0: SQX2 = 0: Sx1X2 = 0: Sn = 0
            For iR = LBound(dArr, 1) + 1 To UBound(dArr, 1)     'Now for each row within the column pairs
                X1 = dArr(iR, iV1): X2 = dArr(iR, iV2)
                If IsNumeric(X1) And IsNumeric(X2) Then
                    SX1 = SX1 + X1
                    SQX1 = SQX1 + X1 * X1
                    SX2 = SX2 + X2
                    SQX2 = SQX2 + X2 * X2
                    Sx1X2 = Sx1X2 + X1 * X2
                    Sn = Sn + 1
                End If
            Next iR
        If Sn > 5 Then
            rArr(c2, c1) = (Sn * Sx1X2 - (SX1 * SX2)) / Sqr((Sn * SQX1 - SX1 ^ 2) * (Sn * SQX2 - SX2 ^ 2)) '  Pearson R
            If Abs(rArr(c2, c1)) < 1 Then
                tArr(c2, c1) = rArr(c2, c1) / Sqr((1 - rArr(c2, c1) ^ 2) / (Sn - 2)) '  t value
            Else
                tArr(c2, c1) = 999
            End If
        Else
 '           rArr(c2, c1) = "#N/A": tArr(c2, c1) = 0
            rArr(c2, c1) = -99: tArr(c2, c1) = 0
        End If
        rArr(c2, c1) = Abs(rArr(c2, c1)) * rArr(c2, c1)  '   Calc R^2
        rArr(c1, c2) = Sn: tArr(c1, c2) = Sn   '  n   - it is also placed in the top diagonal of the R & t matrices
    Next iV2
    Next iV1
    
        '   Delete existing sheet  if necessary
    Application.DisplayAlerts = False
    On Error Resume Next
    Sheets(nShOut).Delete
    Application.DisplayAlerts = True
    On Error GoTo 0
    Sheets.Add().Name = nShOut
    
    Set rOut = Worksheets(nShOut).Cells(rCorn, cCorn).Resize(cc, cc)
    
    Sheets(nShOut).Select
    With Range("A5:BZ250")
        .ClearFormats
        .ClearContents
    End With
    Range("A3") = rtop: Range("A4") = ctop      ' These are saved here for the graphics option
    
    '       Now output the explanatory material
    Range("A1") = "Correlation matrix - Ignores data pairs with missing values"
    With Range("A1:F2")
        .Font.Bold = True
        .Interior.Color = RGB(204, 204, 255)
        .Interior.Pattern = xlSolid
    End With
    Range("B2") = "Generated " & Date & " at " & Time()
    Range("D3") = "Data worksheet is  ": Range("E3") = datasheet
    Range("D4") = "Number of variables  ": Range("E4") = cc
    Range("D5") = "Maximum number data pairs  ": Range("E5") = rc
    Range("D3:D5").HorizontalAlignment = xlRight
    Range("E3:E6").HorizontalAlignment = xlCenter
    
    Range("C6") = "P < 5%": Range("d6") = "P < 1%": Range("e6") = "P < 0.1%": Range("f6") = "r^2 > 0.5"
    With Range("C6")
        .Interior.Color = RGB(204, 255, 204)
        .Interior.Pattern = xlSolid
    End With
    With Range("D6")
        .Interior.Color = RGB(255, 255, 204)
        .Interior.Pattern = xlSolid
    End With
    With Range("E6")
        .Interior.Color = RGB(255, 204, 153)
        .Interior.Pattern = xlSolid
    End With
        With Range("F6")
        .Interior.Color = RGB(204, 255, 204)
        .Interior.Pattern = xlGray8
    End With
    
    rOut.Cells(3, cCorn - 5) = "R^2 values"
    With rOut.Cells(3, cCorn - 5)
        .HorizontalAlignment = xlCenter
        .VerticalAlignment = xlCenter
        .Font.Bold = True
        .Interior.Color = RGB(204, 255, 255)
    End With
    
    rOut.Cells(-1, cc) = "Top diagonal is the number of data pairs"
    With Range(rOut.Cells(-1, 1), rOut.Cells(-1, cc))
        .HorizontalAlignment = xlRight
        .Font.Bold = True
        .Interior.Color = RGB(204, 255, 255)
    End With



    rOut.Value = rArr  '  This transfers the data from the array to the spreadsheet
    
    '  Now for formating
    For ii = 2 To cc
    For jj = 1 To ii - 1
        rOut.Cells(ii, jj).NumberFormat = "#.000;[Red]-#.000"
        If Abs(tArr(ii, jj)) > 1.959 Then       '  <-----   5% prob test
            With rOut.Cells(ii, jj)
                .Interior.Color = RGB(204, 255, 204)
                .Interior.Pattern = xlSolid
            End With
            With rOut.Cells(jj, ii)
                .Interior.Color = RGB(204, 255, 204)
                .Interior.Pattern = xlSolid
            End With
        End If
         If Abs(tArr(ii, jj)) > 2.58 Then       '  <-----   1% prob test
            With rOut.Cells(ii, jj)
                .Interior.Color = RGB(255, 255, 204)
                .Interior.Pattern = xlSolid
            End With
            With rOut.Cells(jj, ii)
                .Interior.Color = RGB(255, 255, 204)
                .Interior.Pattern = xlSolid
            End With
        End If
        If Abs(tArr(ii, jj)) > 3.29 Then       '  <-----   0.1% prob test
            With rOut.Cells(ii, jj)
                .Interior.Color = RGB(255, 204, 153)
                .Interior.Pattern = xlSolid
            End With
            With rOut.Cells(jj, ii)
                .Interior.Color = RGB(255, 204, 153)
                .Interior.Pattern = xlSolid
            End With
        End If
        If Abs(rArr(ii, jj)) > 0.5 Then       '  <-----   Values r2 > 0.5
        With rOut.Cells(ii, jj)
            .Interior.Pattern = xlGray8
        End With
        With rOut.Cells(jj, ii)
            .Interior.Pattern = xlGray8
        End With
        End If
   Next jj
   Next ii
   
   '    Shade diagonal
   For ii = 1 To cc
    rOut.Cells(ii, ii) = ""
        With rOut.Cells(ii, ii)
            .Interior.Color = RGB(224, 224, 224)
            .Interior.Pattern = xlSolid
        End With
   Next ii
   
    For ii = 1 To cc
        rOut.Cells(0, ii) = dArr(1, ii + 1)
        rOut.Cells(0, ii).WrapText = True
        rOut.Cells(ii, 0) = dArr(1, ii + 1)
        rOut.Cells(ii, 0).HorizontalAlignment = xlRight
    Next ii
    Range(rOut.Cells(0, 1), rOut.Cells(0, ii - 1)).Select
    With Selection.Borders(xlEdgeBottom)
        .LineStyle = xlContinuous
        .Weight = xlThick
        .ColorIndex = 1
    End With
    Range(rOut.Cells(1, 0), rOut.Cells(ii - 1, 0)).Select
    With Selection.Borders(xlEdgeRight)
        .LineStyle = xlContinuous
        .Weight = xlThick
        .ColorIndex = 1
    End With
    
    '   Now add button for graphing
    yy = (rCorn + 3) * 16
    ActiveSheet.Buttons.Add(10, yy, 90, 30).Select
    Selection.OnAction = "PairCompare"
    Selection.Characters.Text = "Graph Them"
    With Selection.Characters(Start:=1, Length:=10).Font
        .Name = "Lucida Grande"
        .FontStyle = "Regular"
        .Size = 12
    End With
    Range("C7").Select

Application.ScreenUpdating = True
End Sub
Public Sub PairCompare()
'
'   Plots the pair of variables selected from the correlation table
'

Dim rr1 As Range, rr2 As Range, rrL As Range, rrxy As Range, rrsave As Range
Dim myChtObj As ChartObject
nShOut = "ShOut"

    Application.ScreenUpdating = False
    Set rrsave = Selection
    Var1 = Selection.Row - rCorn + 1
    Var2 = Selection.Column - cCorn + 1
    '       Check whether we have a proper pair for comparison
    If Var1 = Var2 Then
        MsgBox "You cannot select the diagonal for comparision - i.e. a single variable" & Chr(13) & _
                    "You can select cells from either the upper or lower diagonal." & Chr(13) & _
                    "The column variable will be plotted on the X axis and the row variable on the Y axis."
        Exit Sub
    ElseIf Var1 < 1 Or Var2 < 1 Or Var1 > Range("E4") Or Var2 > Range("E4") Then
        MsgBox "You need to select a pair of variables for comparision from the output matrix" & Chr(13) & _
                    "You can select cells from either the upper or lower diagonal." & Chr(13) & _
                    "The column variable will be plotted on the X axis and the row variable on the Y axis."
    Else
        '   Get information about the correlation matrix
        rtop = Range("A3"): ctop = Range("A4"): rc = Range("E5")
        '  Select the original data sheet
        Sheets(Range("E3").Value).Select
        '   Get the X, Y and label data as ranges
        Set rr1 = Range(Cells(rtop + 1, ctop + Var1), Cells(rc + rtop, ctop + Var1))
        Set rr2 = Range(Cells(rtop + 1, ctop + Var2), Cells(rc + rtop, ctop + Var2))
        Set rrL = Range(Cells(rtop + 1, ctop), Cells(rc + rtop, ctop))  '  ISO3 labels
        
        '   Set a place to hold (temporarily) the data to be plotted
        Set rrxy = Sheets(nShOut).Range("BZ3")
        '   Move the data
        nn = 0
        For ii = 1 To rc
            If IsNumeric(rr1(ii)) And IsNumeric(rr2(ii)) Then
                nn = nn + 1
                rrxy.Cells(nn, 1) = rr1(ii): rrxy.Cells(nn, 2) = rr2(ii): rrxy.Cells(nn, 3) = rrL(ii)
            End If
        Next ii
        Set rrplot = Range(rrxy.Cells(1, 1), rrxy.Cells(nn, 2))
        
        '   Move back to the output sheet and clear any previous Charts if necessary
        Sheets(nShOut).Select
        If ActiveSheet.ChartObjects.Count > 0 Then ActiveSheet.ChartObjects.Delete
        
        ' Add a chart and set its position - top of chart is calc to be below correl matrix
        Set myChtObj = ActiveSheet.ChartObjects.Add _
            (Left:=65, Width:=600, Top:=(Range("E4") + 10) * 16, Height:=300)
            
        With myChtObj.Chart
            ' make an XY chart
            .ChartType = xlXYScatter
            ' remove extra series
            Do Until .SeriesCollection.Count = 0
                .SeriesCollection(1).Delete
            Loop
            ' add series from selected range, column by column
            With .SeriesCollection.NewSeries
                .Values = Range(rrxy.Cells(1, 1), rrxy.Cells(nn, 1))
                .XValues = Range(rrxy.Cells(1, 2), rrxy.Cells(nn, 2))
'                .Name = "Not needed at present"
            End With
            '   Apply axis titles
           With .Axes(xlCategory, xlPrimary)
             .HasTitle = True
             With .AxisTitle
               .Font.Size = 12
               .Font.Bold = True
               .Characters.Text = rr2(0)
             End With
           End With
           With .Axes(xlValue, xlPrimary)
             .HasTitle = True
             With .AxisTitle
               .Font.Size = 12
               .Font.Bold = True
               .Characters.Text = rr1(0)
             End With
           End With
           '    Remove legend
           .Legend.Delete
        End With        '   myChtObj.Chart
    End If
    
    Application.ScreenUpdating = False
    CenterOnCell (Cells(Range("E4") + 6, 6))
    rrsave.Select
End Sub


Public Sub CenterOnCell(OnCell As Range)

Dim VisRows As Integer
Dim VisCols As Integer

Application.ScreenUpdating = False
'
' Switch over to the OnCell's workbook and worksheet.
'
OnCell.Parent.Parent.Activate
OnCell.Parent.Activate
'
' Get the number of visible rows and columns for the active window.
'
With ActiveWindow.VisibleRange
    VisRows = .Rows.Count
    VisCols = .Columns.Count
End With
'
' Now, determine what cell we need to GOTO. The GOTO method will
' place that cell reference in the upper left corner of the screen,
' so that reference needs to be VisRows/2 above and VisCols/2 columns
' to the left of the cell we want to center on. Use the MAX function
' to ensure we're not trying to GOTO a cell in row <=0 or column <=0.
'
With Application
    .Goto reference:=OnCell.Parent.Cells( _
        .WorksheetFunction.Max(1, OnCell.Row + _
        (OnCell.Rows.Count / 2) - (VisRows / 2)), _
        .WorksheetFunction.Max(1, OnCell.Column + _
        (OnCell.Columns.Count / 2) - _
        .WorksheetFunction.RoundDown((VisCols / 2), 0))), _
     Scroll:=True
End With

OnCell.Select
Application.ScreenUpdating = True

End Sub






