Option ExplicitPublic FirstYearCol As IntegerPublic LastYearCol As IntegerPublic NumberOfYears As IntegerPublic FirstCountryRow As IntegerPublic LastCountryRow As IntegerPublic NumberOfCountries As IntegerPublic NumberOfMeasures As IntegerPublic FirstYear As IntegerPublic LastYear As IntegerPublic CurrentPath As StringDim xMain As WorkbookDim Reporting As WorkbookPublic Sub DoAll()DoInputDoScoreDoGainEnd SubPublic Sub DoInput()'' Estimates Macro:' Open all files in Column B' Copy Raw sheet to Input Sheet' Extrapolate from last data point into 2012''    LogInfo ("----------------")    LogInfo ("Input preparation is running")      'Dim FirstFile As RangeDim ShRaw As WorksheetDim ShInput As WorksheetDim AFGCell As StringDim FirstFile As RangeDim MasterFiles As IntegerDim ToDo As IntegerDim n As IntegerDim FilePath As StringDim ReportingPath As String              AFGCell = Sheets("Info").Range("C4").Value      ' Location of first country ISO3    FirstYearCol = Range(AFGCell).Column + 2    FirstYear = Sheets("Info").Range("C7").Value    LastYear = Sheets("Info").Range("C6").Value    NumberOfYears = LastYear - FirstYear    LastYearCol = FirstYearCol + NumberOfYears    FirstCountryRow = Range(AFGCell).Row    LastCountryRow = FirstCountryRow + Sheets("Info").Range("C5").Value    NumberOfCountries = LastCountryRow - FirstCountryRow    LogInfo NumberOfYears & " years and " & NumberOfCountries & " countries"    '         Get the workbook files    Set FirstFile = Sheets("Files").Range("B4")    MasterFiles = FirstFile.End(xlDown).Row - 3                      ' Avoid blanks in list of xlDown will fail    On Error Resume Next    ToDo = Range(FirstFile.Cells(1, 2), FirstFile.Cells(MasterFiles, 2)).SpecialCells(xlCellTypeBlanks).Count    On Error GoTo 0        LogInfo ToDo & " files to run out of " & MasterFiles    CurrentPath = ActiveWorkbook.Path        'Open Reporting sheet    'ReportingPath = CurrentPath & ":" & "Reporting.xls"    'Reporting.Open Filename:=FilePath    'LogInfo "Opening Reporting File: " & FilePath        For n = 1 To MasterFiles        If FirstFile.Cells(n, 2) = "" Then            FilePath = CurrentPath & ":" & FirstFile.Cells(n, 1).Value            If FileExists(FilePath) Then                Workbooks.Open FileName:=FilePath, updateLinks:=False                LogInfo "Proccesing file: " & FilePath                If Not SheetExists("Raw") Then                    LogInfo "Sheet Raw not found. CREATING one FROM Raw0. "                    Call PrepSheet("Raw", "Raw0", ActiveWorkbook)                End If                                'Clear/Create Sheet Input                Call PrepSheet("Input", "Raw", ActiveWorkbook)               'Extend forward last Value and backwards first Value               'Interpolate inside Gaps               Call InterpolateInput               FirstFile.Cells(n, 2).Value = 1 'Done                ActiveWorkbook.Save                ActiveWindow.Close            Else                LogInfo "Cannot find file" & FilePath            End If                                End If 'File is included    Next n  'done ActiveWorkbook.SaveEnd SubPublic Sub DoScore()'' Makes Scores:' Open all files in Column B' Copy Raw sheet layout to Score Sheet' Converts Input to Score''    LogInfo ("----------------")    LogInfo ("Score preparation is running")      'Dim FirstFile As RangeDim ShInput As WorksheetDim ShScore As WorksheetDim AFGCell As StringDim FirstFile As RangeDim MasterFiles As IntegerDim ToDo As IntegerDim n As IntegerDim FilePath As StringDim xRange As RangeDim LowThreshold As SingleDim HighThreshold As SingleDim Direction As Integer              AFGCell = Sheets("Info").Range("C4").Value      ' Location of first country ISO3    FirstYearCol = Range(AFGCell).Column + 2    FirstYear = Sheets("Info").Range("C7").Value    LastYear = Sheets("Info").Range("C6").Value    NumberOfYears = LastYear - FirstYear    LastYearCol = FirstYearCol + NumberOfYears    FirstCountryRow = Range(AFGCell).Row    LastCountryRow = FirstCountryRow + Sheets("Info").Range("C5").Value    NumberOfCountries = LastCountryRow - FirstCountryRow    LogInfo NumberOfYears & " years and " & NumberOfCountries & " countries"    '         Get the workbook files    Set FirstFile = Sheets("Files").Range("B4")    MasterFiles = FirstFile.End(xlDown).Row - 3                      ' Avoid blanks in list of xlDown  or it will fail to find all        On Error Resume Next    ToDo = Range(FirstFile.Cells(1, 3), FirstFile.Cells(MasterFiles, 3)).SpecialCells(xlCellTypeBlanks).Count    On Error GoTo 0    LogInfo ToDo & " files to run out of " & MasterFiles    CurrentPath = ActiveWorkbook.Path        For n = 1 To MasterFiles        If FirstFile.Cells(n, 3) = "" Then            FilePath = CurrentPath & ":" & FirstFile.Cells(n, 1).Value            If FileExists(FilePath) Then                'Run this measure, but first readThreshold                FirstFile.Cells(n, 5).Select                LowThreshold = FirstFile.Cells(n, 4)                HighThreshold = FirstFile.Cells(n, 5)                Direction = FirstFile.Cells(n, 6)                    Workbooks.Open FileName:=FilePath, updateLinks:=False                LogInfo "Proccesing file: " & FilePath                LogInfo "Limits " & LowThreshold & " to " & HighThreshold & " dir: " & Direction                                If SheetExists("Input") Then                                        'Clear/Create Sheet Score copying Input                    Call PrepSheet("Score", "Input", ActiveWorkbook)                                        'Score Input values on sheet based on thresholds                    Call ScoreSheet(LowThreshold, HighThreshold, Direction)                                        FirstFile.Cells(n, 3).Value = 1 'Done                    ActiveWorkbook.Save                    ActiveWindow.Close                Else                    LogInfo "Sheet Input not found. Error."                End If            Else                LogInfo "Cannot find file" & FilePath            End If                                End If 'File is included    Next n 'next file     'done  ActiveWorkbook.SaveEnd SubPublic Sub AgriCapacity()Dim Agri As WorkbookDim Fertilizers As VariantDim Tractors As VariantDim Irrigation As VariantDim FilePath As StringDim AFGCell As StringDim xYear As IntegerDim Country As IntegerCurrentPath = ActiveWorkbook.PathAFGCell = Sheets("Info").Range("C4").Value      ' Location of first country ISO3FirstYearCol = Range(AFGCell).Column + 2FirstYear = Sheets("Info").Range("C7").ValueLastYear = Sheets("Info").Range("C6").ValueNumberOfYears = LastYear - FirstYearLastYearCol = FirstYearCol + NumberOfYearsFirstCountryRow = Range(AFGCell).RowLastCountryRow = FirstCountryRow + Sheets("Info").Range("C5").ValueNumberOfCountries = LastCountryRow - FirstCountryRow    Set Agri = Workbooks.Open(CurrentPath & ":" & "Agric Capacity.xls", updateLinks:=False)Application.ScreenUpdating = FalseWith Agri.Sheets("Score")    For xYear = FirstYearCol To LastYearCol        For Country = FirstCountryRow To LastCountryRow                        Fertilizers = GetValue(CurrentPath, "tt-Fertilizers.xls", "Score", Country, xYear)            Tractors = GetValue(CurrentPath, "tt-Machinery.xls", "Score", Country, xYear)            Irrigation = GetValue(CurrentPath, "tt-irrigated.xls", "Score", Country, xYear)            Agri.Sheets("Score").Activate                        'LogInfo "" & CStr(Fertilizers) & " " & CStr(Tractors) & " " & CStr(Irrigation)            'Case none is anumber            Dim test As Integer                        test = IsNumeric(Fertilizers) + IsNumeric(Tractors) + IsNumeric(Irrigation)            Select Case test                Case -3                    'All numeric                    Dim MaxVal As Single                    MaxVal = Application.WorksheetFunction.Max(Fertilizers, Tractors, Irrigation)                    Cells(Country, xYear).Value = Application.WorksheetFunction.Sum(Fertilizers, Tractors, Irrigation, -MaxVal) / 2#                    'LogInfo "        All numeric:" & Application.WorksheetFunction.Sum(Fertilizers, Tractors, Irrigation, -MaxVal) / 2#                    'test = test                Case -1                    'Only one numeric                    'Fertilizers = WorksheetFunction.IfError(Fertilizers, 0)                    'Tractors = WorksheetFunction.IfError(Tractors, 0)                    'Irrigation = WorksheetFunction.IfError(Irrigation, 0)                    'Cells(Country, xYear).Value = (1 + Application.WorksheetFunction.Max(Fertilizers, Tractors, Irrigation)) / 2#                    Cells(Country, xYear).Value = "#N/A"                                        'LogInfo "        Only one numeric:" & Application.WorksheetFunction.Max(Fertilizers, Tractors, Irrigation)                    'test = test                Case -2                    'One is not numeric                    Fertilizers = WorksheetFunction.IfError(Fertilizers, 0)                    Tractors = WorksheetFunction.IfError(Tractors, 0)                    Irrigation = WorksheetFunction.IfError(Irrigation, 0)                    Cells(Country, xYear).Value = Application.WorksheetFunction.Sum(Fertilizers, Tractors, Irrigation) / 2#                    'LogInfo "        2 numeric:" & Application.WorksheetFunction.Sum(Fertilizers, Tractors, Irrigation) / 2#                    'test = test                Case 0                    'All non numeric                    Cells(Country, xYear).Value = "#N/A"                    'test = test                                    End Select                        Cells(Country, xYear).Select                                Next Country        LogInfo "Doing AgriCapacity for " & 1995 + xYear - 5    Next xYearEnd WithActiveWorkbook.SaveActiveWorkbook.CloseEnd SubFunction GetValue(Path As String, File As String, Sheet As String, xRow As Integer, xColumn As Integer)     'Retrieves a value from a closed workbook    Dim txt As String, wb As Workbook, ws As Worksheet    Application.ScreenUpdating = False    txt = Path & ":" & File    On Error Resume Next    Set wb = Workbooks(txt)    On Error GoTo 0        If Not FileExists(txt) Then        MsgBox txt & " does not exist"    Else        If Not IsWbOpen(File) Then            'open            Set wb = Workbooks.Open(txt)        Else            Set wb = Workbooks(File)        End If        On Error Resume Next        Set ws = wb.Sheets(Sheet)        If Not ws Is Nothing Then            GetValue = ws.Cells(xRow, xColumn).Value            'wb.Close        Else            MsgBox ws.Name & " does not exist"        End If        Err.Clear    End If    'Application.ScreenUpdating = TrueEnd FunctionFunction IsWbOpen(wbName As String) As Boolean    Dim i As Long    For i = Workbooks.Count To 1 Step -1        If Workbooks(i).Name = wbName Then Exit For    Next    If i <> 0 Then IsWbOpen = TrueEnd FunctionPublic Sub DoGain()' Creates Yearly Sheets with measures in columns and countries in rows.' Adds columns for partial and total scores.' Saves results in different Sheets on file GAIN.xls        LogInfo ("----------------")    LogInfo ("DoGain scores running")      Dim ShInput As WorksheetDim ShScore As WorksheetDim AFGCell As StringDim FirstFile As RangeDim AllFiles As RangeDim MasterFiles As IntegerDim ToDo As IntegerDim Measure As IntegerDim Country As IntegerDim Year As IntegerDim FirstYear As IntegerDim LastYear As IntegerDim i As IntegerDim FilePath As StringDim GainPath As StringDim xGain As WorkbookDim xMain As WorkbookDim GainFile As StringDim CurrentMeasure As WorkbookDim MeasureName As StringDim PartialsList As RangeDim PartialItem As RangeDim DataRange As RangeDim ResultRange As RangeDim Labels As Range          AFGCell = Sheets("Info").Range("C4").Value      ' Location of first country ISO3    GainFile = Sheets("Info").Range("C8").Value + ".xls"    Set xMain = ActiveWorkbook    CurrentPath = xMain.Path    FirstYearCol = Range(AFGCell).Column + 2    FirstYear = Sheets("Info").Range("C7").Value    LastYear = Sheets("Info").Range("C6").Value    NumberOfYears = LastYear - FirstYear    LastYearCol = FirstYearCol + NumberOfYears    FirstCountryRow = Range(AFGCell).Row    LastCountryRow = FirstCountryRow + Sheets("Info").Range("C5").Value    NumberOfCountries = LastCountryRow - FirstCountryRow    LastYear = Sheets("Info").Range("C6").Value    FirstYear = Sheets("Info").Range("C7").Value        LogInfo NumberOfYears & " years and " & NumberOfCountries & " countries"    '         Get the workbook files    Set FirstFile = Sheets("Files").Range("B4")    Set AllFiles = FirstFile.End(xlDown)    MasterFiles = FirstFile.End(xlDown).Row - 3                      ' Avoid blanks in list of xlDown  or it will fail to find all    NumberOfMeasures = MasterFiles 'Range(FirstFile.Cells(1, 7), FirstFile.Cells(MasterFiles, 7)).SpecialCells(xlCellTypeBlanks).Count    'ToDo = Range(FirstFile.Cells(1, 2), FirstFile.Cells(MasterFiles, 2)).SpecialCells(xlCellTypeBlanks).Count    LogInfo ToDo & " measures. "        Set PartialsList = xMain.Worksheets("Info").Range("D13:D25") 'list of partials to make        ' Count Files    LogInfo NumberOfMeasures & " measures in total"    LogInfo Sheets("Info").Range("C21").Value & " for Readiness, " & Sheets("Info").Range("C14").Value & " for Vulnerability"    LogInfo "V: " & Sheets("Info").Range("E17").Value & " for Exposure, " & Sheets("Info").Range("E18").Value & "  for Sensitivity, " & Sheets("Info").Range("E19").Value & "  for Capacity"    LogInfo "V: " & Sheets("Info").Range("E13").Value & " for Food, " & Sheets("Info").Range("E14").Value & "  for Water, " & Sheets("Info").Range("E15").Value & "  for Health, " & Sheets("Info").Range("E16").Value & "  for Infrastructure"    LogInfo "R: " & Sheets("Info").Range("E22").Value & "  for Social," & Sheets("Info").Range("E21").Value & "  for Governance, " & Sheets("Info").Range("E20").Value & "  for Economic"        'Prepare Workbook for Results    FilePath = CurrentPath & ":" & GainFile    GainPath = FilePath 'saved for later                'Do Yearly    If FileExists(FilePath) Then                Workbooks.Open FileName:=FilePath, updateLinks:=False 'Moving focus here.                Set xGain = ActiveWorkbook                LogInfo "Preparing yearly Gain input file"               'GoTo skip                'Create Sheets for years                With xGain                    For Year = FirstYear To LastYear                        'LogInfo "DEVELOPER- Bypassing the clearing of Yearly sheets, it just takes too much time"                        'Exit For                        Call PrepSheet("" & Year, "Gain", xGain)                    Next Year                End With                                        '   read all measures, placing data in Sheets, by Year                    For Measure = 1 To MasterFiles                            'LogInfo "DEVELOPER- Bypassing the making of Yearly sheets, it just takes too much time"                    'Exit For                                MeasureName = FirstFile.Cells(Measure, 1).Value                    FilePath = CurrentPath & ":" & MeasureName                    If FileExists(FilePath) Then                    Workbooks.Open FileName:=FilePath, updateLinks:=False                    Set CurrentMeasure = ActiveWorkbook                    If SheetExists("Score") Then                    LogInfo "" & MeasureName                    For Year = FirstYear To LastYear                            i = Year - FirstYear 'index of column from 0 to NumberOfYears                            xGain.Worksheets("" & Year).Cells(FirstCountryRow - 1, FirstYearCol + Measure - 1).Value = MeasureName  'colunm label                            CurrentMeasure.Worksheets("Score").Select                            CurrentMeasure.Worksheets("Score").Range(Cells(FirstCountryRow, FirstYearCol + i), Cells(LastCountryRow, FirstYearCol + i)).Copy _                                Destination:=xGain.Worksheets("" & Year).Cells(FirstCountryRow, FirstYearCol + Measure - 1)                    Next 'years                Else                    LogInfo "Sheet Score not found. Error."                    'File should have at least a sheet called Gain with the basic layout (countrynames starting with AFG in the same cell)                End If            Else                LogInfo "Cannot find file" & FilePath                'cant find measure file            End If            CurrentMeasure.Close savechanges:=False        Next Measure        Else        LogInfo "Cannot find file" & FilePath    End If    ActiveWorkbook.Saveskip:    'Do partials    If FileExists(FilePath) Then                Workbooks.Open FileName:=FilePath, updateLinks:=False 'Moving focus here.                For Each PartialItem In PartialsList                                    LogInfo "Preparing partial " & PartialItem.Value                    With xGain                        Call PrepSheet(PartialItem.Value, "Gain", xGain) 'also timestamp                    End With                                        xMain.Sheets("Files").Activate                    Set Labels = ActiveSheet.Range("H4:J45")                                        For Year = FirstYear To LastYear                        If PartialItem.Value <> "Gain" Then                            Call Aggregate(xGain, Year, PartialItem, Labels)                        Else                            Call R_V(xGain, Year)                        End If                                            Next Year                Next PartialItem               'Call PrepSheet("Reporting", "Gain")  'TODO    End If    'doneActiveWorkbook.SavexGain.SaveEnd SubPublic Sub DoPreInput()'' Calculate pre-inpute value' These are metrics than need some calculations before running the pipeline' For Gain 2011 there are 2' -Health staff aggregates 2*doctors + nurses' - Agric Capacity averages the best 2 scores out of 3 measures'' Open all files in Column B' Copy Raw sheet to Input Sheet' Extrapolate from last data point into 2012''    LogInfo ("----------------")    LogInfo ("Input preparation is running")      'Dim FirstFile As RangeDim ShRaw As WorksheetDim ShInput As WorksheetDim AFGCell As StringDim FirstFile As RangeDim MasterFiles As IntegerDim ToDo As IntegerDim n As IntegerDim FilePath As StringDim FileOutput As StringDim FileInput1 As StringDim FileInput2 As StringDim FileInput3 As StringDim WOutput As WorkbookDim WInput1 As WorkbookDim WInput2 As WorkbookDim WInput3 As Workbook              AFGCell = Sheets("Info").Range("C4").Value      ' Location of first country ISO3    FirstYearCol = Range(AFGCell).Column + 2    FirstYear = Sheets("Info").Range("C7").Value    LastYear = Sheets("Info").Range("C6").Value    NumberOfYears = LastYear - FirstYear    LastYearCol = FirstYearCol + NumberOfYears    FirstCountryRow = Range(AFGCell).Row    LastCountryRow = FirstCountryRow + Sheets("Info").Range("C5").Value    NumberOfCountries = LastCountryRow - FirstCountryRow    LogInfo NumberOfYears & " years and " & NumberOfCountries & " countries"        LogInfo "Doing Health Staff"        '         Get the workbook files        CurrentPath = ActiveWorkbook.Path        FileOutput = "Health Staff.xls"    FileInput1 = "Health Physicians.xls"    FileInput2 = "Health Nurses MW.xls"        'Output    FilePath = CurrentPath & ":" & FileOutput    If FileExists(FilePath) Then        Workbooks.Open FileName:=FilePath, updateLinks:=False        Set WOutput = ActiveWorkbook        If SheetExists("Raw") Then            LogInfo "Proccesing file: " & FilePath        Else            'Make Sheet "Raw"        End If    Else        'Make file    End If        FilePath = CurrentPath & ":" & FileInput1    If FileExists(FilePath) Then        Workbooks.Open FileName:=FilePath, updateLinks:=False        Set WInput1 = ActiveWorkbook        If SheetExists("Raw") Then            LogInfo "Proccesing file: " & FilePath        Else            'Make Sheet "Raw"        End If    Else        'Make file    End If        FilePath = CurrentPath & ":" & FileInput2    If FileExists(FilePath) Then        Workbooks.Open FileName:=FilePath, updateLinks:=False        Set WInput2 = ActiveWorkbook        If SheetExists("Raw") Then            LogInfo "Proccesing file: " & FilePath        Else            'Make Sheet "Raw"        End If    Else        'Make file    End If                            ActiveWorkbook.Save                    ActiveWindow.Close     'done End SubPublic Sub Aggregate(xGain As Workbook, Year As Integer, Partial As Range, Labels As Range)Dim Label As RangeDim Score As DoubleDim Normalize As DoubleDim DataMeasure As VariantDim DataCount As IntegerDim Country As IntegerDim Threshold As IntegerDim DataRange As RangeDim ResultRange As RangexGain.Sheets(CStr(Year)).ActivateSet DataRange = xGain.Sheets(CStr(Year)).Range(xGain.Sheets(CStr(Year)).Cells(FirstCountryRow, FirstYearCol), xGain.Sheets(CStr(Year)).Cells(LastCountryRow, FirstYearCol + NumberOfMeasures - 1))xGain.Sheets(Partial.Value).ActivateSet ResultRange = xGain.Sheets(Partial.Value).Range(xGain.Sheets(Partial.Value).Cells(FirstCountryRow, FirstYearCol), xGain.Sheets(Partial.Value).Cells(LastCountryRow, LastYearCol))ResultRange.SelectThreshold = Partial.Offset(0, 4)LogInfo "Doing " & Partial.Value & " for " & Year & ". Threshold is " & ThresholdFor Country = 1 To NumberOfCountries + 1    Score = 0#    DataCount = 0    Normalize = 0#    For Each Label In Labels 'Run down labels of partials        'LogInfo Label.Value        If Label.Value = Partial.Value Then 'Filter only relevant Partial        xGain.Sheets(CStr(Year)).Activate        'DataRange.Select          DataMeasure = DataRange.Columns(Label.Row - 3).Rows(Country).Value          'LogInfo Label.Value & " Row: " & Label.Row - 3 & " Value: " & CStr(DataMeasure)                     If IsNumeric(DataMeasure) Then                'LogInfo country & " Weight: " & Label.Offset(0, 3).Value & "Measure: " & DataMeasure.Value                Score = Score + (DataMeasure * Label.Offset(0, 3).Value)                Normalize = Normalize + Label.Offset(0, 3).Value                DataCount = DataCount + 1            End If 'Data is number        End If 'Data belongs to partial    Next Label    'LogInfo "Score " & Score / Normalize & " data count " & DataCount    If DataCount > 0 Then      If DataCount >= Threshold Then        'good data. place results        'ResultRange.Rows(country).Columns(1).Select        FirstYear = 1995        xGain.Sheets(Partial.Value).Cells(FirstCountryRow, FirstYearCol).Offset(Country - 1, Year - FirstYear + 1 - 1).Value = Score / Normalize        'Offset is 0 based, not 1 based, like Cells.        'LogInfo DataRange.Columns(0).Rows(country) & " " & Year & " done"      Else        'Not much data        xGain.Sheets(Partial.Value).Cells(FirstCountryRow, FirstYearCol).Offset(Country - 1, Year - FirstYear + 1 - 1).Value = "#N/A"        LogInfo DataRange.Columns(0).Rows(Country) & "-> Only " & DataCount & " values. We need " & Threshold     End If    Else        'no data        xGain.Sheets(Partial.Value).Cells(FirstCountryRow, FirstYearCol).Offset(Country - 1, Year - FirstYear + 1 - 1).Value = "#N/A"        LogInfo DataRange.Columns(0).Rows(Country) & ": No values found for " & Partial    End IfNext CountryEnd Sub                        Public Sub R_V(xGain As Workbook, Year As Integer)Dim R As DoubleDim V As DoubleDim Country As IntegerFirstYear = 1995xGain.ActivateWith xGainFor Country = FirstCountryRow To LastCountryRow        R = -1#        V = -1#      ActiveWorkbook.Sheets("Readiness").Rows(Country).Columns(Year - FirstYear + FirstYearCol).Select       If IsNumeric(ActiveWorkbook.Sheets("Readiness").Rows(Country).Columns(Year - FirstYear + FirstYearCol).Value) Then            R = ActiveWorkbook.Sheets("Readiness").Rows(Country).Columns(Year - FirstYear + FirstYearCol).Value        End If'        ActiveWorkbook.Sheets("Vulnerability").Rows(country).Columns(Year - FirstYear + FirstYearCol).Select        If IsNumeric(ActiveWorkbook.Sheets("Vulnerability").Rows(Country).Columns(Year - FirstYear + FirstYearCol).Value) Then            V = ActiveWorkbook.Sheets("Vulnerability").Rows(Country).Columns(Year - FirstYear + FirstYearCol).Value        End If       If R <> -1 Then        If V <> -1 Then            ActiveWorkbook.Sheets("Gain").Rows(Country).Columns(Year - FirstYear + FirstYearCol).Value = (R - V + 1#) * 50#            'LogInfo "" & R & V        Else        LogInfo "No V for " & ActiveWorkbook.Sheets("Readiness").Rows(Country).Columns(FirstYearCol - 1) & " " & Year        End If        Else        LogInfo "No R for " & ActiveWorkbook.Sheets("Readiness").Rows(Country).Columns(FirstYearCol - 1) & " " & Year        End If Next Country        End With'xGain.Sheets("Readiness").Select'R_VRange = RRange - VRangeLogInfo "Gain Done for " & YearEnd SubPublic Sub PrepSheet(SheetName As String, SourceSheet As String, Optional xWorkbook As Workbook)If IsMissing(xWorkbook) Then            Set xWorkbook = ActiveWorkbookElse            xWorkbook.ActivateEnd If'Clear/Create SheetWith xWorkbook    If SheetExists(SheetName) Then        Sheets(SheetName).Select       '  Moving focus there.        Sheets(SheetName).Range(Cells(FirstCountryRow, FirstYearCol), Cells(LastCountryRow, LastYearCol)).Clear 'Data block        Range("A1") = "Sheet cleared by " & Application.UserName & " on " & TimeValue(Now)        LogInfo "Sheet " & SheetName & " Cleared"     Else        xWorkbook.Sheets.Add.Name = SheetName        Range("A1") = "Sheet created by " & Application.UserName & " on " & TimeValue(Now)        LogInfo "Sheet " & SheetName & " Created"      End If      xWorkbook.Sheets(SourceSheet).Activate      xWorkbook.Sheets(SourceSheet).Range(Cells(FirstCountryRow - 1, FirstYearCol - 2), Cells(LastCountryRow, LastYearCol)).Copy      'Copy also Country ISO3s, Names and Years header.      Sheets(SheetName).Cells(FirstCountryRow - 1, FirstYearCol - 2).PasteSpecial Paste:=xlPasteValues      'Range(Cells(FirstCountryRow - 1, FirstYearCol - 2), Cells(LastCountryRow, LastYearCol)).NumberFormat = "#.000" 'Format to x.xxx      xWorkbook.Sheets(SheetName).ActivateEnd With                    End SubPublic Sub InterpolateInput()''Extrapolate on both ends with the closest data'Interpolate linearly when gaps are in the middle.'Dim GapSize As IntegerDim GapEnd As IntegerDim PreGap As SingleDim PostGap As SingleDim Country As IntegerDim xCell As RangeDim yCell As RangeDim Slope As SingleDim i As IntegerFor Country = FirstCountryRow To LastCountryRow    Set xCell = ActiveSheet.Range(Cells(Country, FirstYearCol), Cells(Country, LastYearCol))    Dim TestEmptyRow As Range    On Error Resume Next    xCell.SpecialCells(xlCellTypeConstants, xlErrors).Clear  'Clear errors    xCell.SpecialCells(xlCellTypeConstants, xlTextValues).Clear  'Clear text    Set TestEmptyRow = xCell.SpecialCells(xlCellTypeBlanks)    If TestEmptyRow Is Nothing Then Set TestEmptyRow = xCell.Columns(1) 'ugly hack to avoid error later    On Error GoTo 0            If TestEmptyRow.Count = NumberOfYears + 1 Then        LogInfo "Empty Row -> " & ActiveSheet.Cells(Country, FirstYearCol - 1)        xCell.Value = "#N/A"        xCell.Font.ColorIndex = 0    'Black        xCell.Font.Bold = True        GoTo NextCountry    End If                'Check First Column    If xCell.Columns(1).Value = "" Then        'Extrapolate from first entry        GapSize = xCell.Columns(1).End(xlToRight).Column - FirstYearCol        xCell.Range(Cells(1, 1), Cells(1, GapSize)) = xCell.Columns(GapSize + 1).Value        xCell.Range(Cells(1, 1), Cells(1, GapSize)).Font.ColorIndex = 3    'Blue   'IT DOESNT  WORK always        xCell.Range(Cells(1, 1), Cells(1, GapSize)).Font.Bold = True        LogInfo ("Extrapolate to 1995. Gap Size: " & GapSize & " -> " & ActiveSheet.Cells(Country, FirstYearCol - 1))    End If        'Check Last Column    If xCell.Columns(NumberOfYears + 1).Value = "" Then        'Extrapolate from last entry        GapSize = LastYearCol - xCell.Columns(NumberOfYears + 1).End(xlToLeft).Column - 1        xCell.Range(Cells(1, NumberOfYears + 1 - GapSize), Cells(1, NumberOfYears + 1)) = xCell.Columns(NumberOfYears - GapSize).Value        xCell.Range(Cells(1, NumberOfYears + 1 - GapSize), Cells(1, NumberOfYears + 1)).Font.ColorIndex = 5  'Red   'IT DOESNT  WORK always        xCell.Range(Cells(1, NumberOfYears + 1 - GapSize), Cells(1, NumberOfYears + 1)).Font.Bold = True        LogInfo ("Extrapolate to 2012. Gap Size: " & GapSize + 1 & " -> " & ActiveSheet.Cells(Country, FirstYearCol - 1))    End If        If Application.CountBlank(xCell) <> 0 Then    'Check Gaps in the middle    Set yCell = xCell.Range("a1")        For Each yCell In xCell.SpecialCells(xlCellTypeBlanks)            If yCell.Value = "" Then               'Gap Found              'Interpolate              GapSize = yCell.End(xlToRight).Column - yCell.Column              PreGap = yCell.Offset(0, -1).Value              PostGap = yCell.Offset(0, GapSize).Value              LogInfo ("Gap Size: " & GapSize & ". Slope: " & Slope & " -> " & ActiveSheet.Cells(Country, FirstYearCol - 1))             Slope = (PostGap - PreGap) / (GapSize + 1)                          'Filler              For i = 0 To GapSize - 1                   yCell.Offset(0, i).Font.ColorIndex = 4    'Green                   yCell.Offset(0, i).Font.Bold = True                   yCell.Offset(0, i).Value = PreGap + ((i + 1) * Slope)               Next 'filler done            End If 'run through gap length done        Next 'next gap in row    End If 'row had gapsNextCountry:Next 'next countryEnd SubPublic Sub ReportingLevel()''Count number of numeric Values in RawDim Country As IntegerDim xCell As RangeDim yCell As RangeFor Country = FirstCountryRow To LastCountryRow    Set xCell = ActiveSheet.Range(Cells(Country, FirstYearCol), Cells(Country, LastYearCol))    Set yCell = xCell.Range("a1")        For Each yCell In xCell            '        NextNextCountry:Next 'next countryEnd SubPublic Sub ScoreSheet(LowThreshold As Single, HighThreshold As Single, Direction As Integer)''Convert Input values into Scores'Scores are non-dimensional and capped between chosen thresholds (specified on Sheet Info)'Direction means if higher input values are better or worse.'High score is better in Readiness always, and low score in Vulnerability alwaysDim xRange As RangeDim yRange As RangeDim Denominator As RangeDim Substract As Range'initialize, but it's yet emptySet Denominator = Range("H1")Set Substract = Range("H2")Range("G1").Value = "Denominator"Range("G2").Value = "Substract"Range("G3").Value = "Direction"Range("I1").Value = "Low"Range("I2").Value = "High"Range("H3").Value = DirectionRange("J1").Value = LowThresholdRange("J2").Value = HighThresholdSet xRange = Sheets("Score").Range(Cells(FirstCountryRow, FirstYearCol), Cells(LastCountryRow, LastYearCol)) 'All DataSet yRange = xRange.SpecialCells(xlCellTypeConstants, xlNumbers) 'Valid Data (not blank or errors)  'Score function for direction 1 is ' (x-L)/(H-L) ' which is ' x/(H-L) - L/(H-L) 'i.e. First Divide then substract   'Score function for direction -1 is ' 1- [(x-L)/(H-L)] ' which is ' x/(L-H) + H/(H-L) ' i.e. First divide then Add 'This process the whole set of numeric cells at once. Should be quick. Application.CutCopyMode = False If Direction = "1" Then    Denominator.Value = (HighThreshold - LowThreshold)    Substract.Value = LowThreshold / (HighThreshold - LowThreshold)    Denominator.Copy    yRange.PasteSpecial xlPasteValues, xlPasteSpecialOperationDivide    Substract.Copy    yRange.PasteSpecial xlPasteValues, xlPasteSpecialOperationSubtract Else 'Direction is -1    Denominator.Value = (LowThreshold - HighThreshold)    Substract.Value = HighThreshold / (HighThreshold - LowThreshold)    Denominator.Copy    yRange.PasteSpecial xlPasteValues, xlPasteSpecialOperationDivide    Substract.Copy    yRange.PasteSpecial xlPasteValues, xlPasteSpecialOperationAdd End If  Application.CutCopyMode = True   LogInfo "Denominator " & Denominator.Value & " Substract " & Substract.Value & " dir: " & Direction                     'Do the capping from 0 to 1'tried a fastest way but seems fishy: http://stackoverflow.com/questions/8827559'I'll use a memory arrayDim AllCells As VariantDim i As LongDim j As LongAllCells = xRange ' Load  cells to the Variant array. Needs to be xCell, not only yCellFor i = LBound(AllCells, 1) To UBound(AllCells, 1)    For j = LBound(AllCells, 2) To UBound(AllCells, 2)        'LogInfo "" & AllCells(i, j)        If IsNumeric(AllCells(i, j)) Then            If AllCells(i, j) > 1 Then AllCells(i, j) = 1  ' Cap values above 1.            If AllCells(i, j) < 0 Then AllCells(i, j) = 0 ' Cap values below 0.        End If    Next jNext ixRange = AllCells ' Write Variant array back to sheet.LogInfo "Scores completed"End SubPublic Sub ConvertToCsv()Dim FileName As StringDim Measures As Range, Measure As RangeDim Partials As Range, Partial As RangeDim xSheet As VariantDim xSheets(0 To 3) As StringDim AFGCell As StringDim FirstFile As RangeDim MasterFiles As IntegerDim ToDo As IntegerDim n As IntegerDim FilePath As StringDim ReportingPath As StringxSheet(0) = "Raw0"xSheet(1) = "Raw"xSheet(2) = "Input"xSheet(3) = "Score"AFGCell = Sheets("Info").Range("C4").Value      ' Location of first country ISO3    FirstYearCol = Range(AFGCell).Column + 2    FirstYear = Sheets("Info").Range("C7").Value    LastYear = Sheets("Info").Range("C6").Value    NumberOfYears = LastYear - FirstYear    LastYearCol = FirstYearCol + NumberOfYears    FirstCountryRow = Range(AFGCell).Row    LastCountryRow = FirstCountryRow + Sheets("Info").Range("C5").Value    NumberOfCountries = LastCountryRow - FirstCountryRow    LogInfo NumberOfYears & " years and " & NumberOfCountries & " countries"    '         Get the workbook files    Set FirstFile = Sheets("Files").Range("B4")    MasterFiles = FirstFile.End(xlDown).Row - 3                      ' Avoid blanks in list of xlDown  or it will fail to find all        On Error Resume Next    ToDo = Range(FirstFile.Cells(1, 3), FirstFile.Cells(MasterFiles, 3)).SpecialCells(xlCellTypeBlanks).Count    On Error GoTo 0    LogInfo ToDo & " files to run out of " & MasterFiles    CurrentPath = ActiveWorkbook.Path        For n = 1 To MasterFiles        If FirstFile.Cells(n, 3) = "" Then            FilePath = CurrentPath & ":" & FirstFile.Cells(n, 1).Value            If FileExists(FilePath) Then                'Run this measure, but first readThreshold                FirstFile.Cells(n, 14).Select                 Workbooks.Open FileName:=FilePath, updateLinks:=False                LogInfo "Proccesing file: " & FilePath                For Each xSheet In xSheets                  If SheetExists("Input") Then                    'Do csv export'                  Else                    LogInfo "Sheet Input not found. Error."                  End If                Next xSheet            Else                LogInfo "Cannot find file" & FilePath            End If        End If    Next n 'measure                    For Each Measure In Measures    'Open Files for measures    For Each xSheet In Worksheets        CsvExport (FileName)    Next xSheetNext Measure'Open Partialsin Gain FileFor Each Partial In Partials        CsvExport (FileName)Next PartialEnd SubSub CsvExport(FileName As String)    Range("C5:U197").Select    Selection.Copy    Workbooks.Add    ActiveSheet.Paste    ActiveWorkbook.SaveAs FileName:= _    FileName _    , FileFormat:=xlCSV, CreateBackup:=False    Application.DisplayAlerts = False    ActiveWorkbook.Close    Application.DisplayAlerts = True     End SubFunction FileExists(ByVal AFileName As String) As Boolean'  Looks within current directory    On Error GoTo Catch    FileSystem.FileLen AFileName    FileExists = True    GoTo FinallyCatch:        FileExists = FalseFinally:End FunctionFunction SheetExists(SheetName As String) As Boolean' returns TRUE if the sheet exists in the active workbook    SheetExists = False    On Error GoTo NoSuchSheet    If Len(Sheets(SheetName).Name) > 0 Then        SheetExists = True        Exit Function    End IfNoSuchSheet:End FunctionSub LogInfo(LogMessage As String)Dim LogFileName As StringLogFileName = CurrentPath & ":Gain-dev.LOG"Dim FileNum As Integer    FileNum = FreeFile ' next file number    Open LogFileName For Append As #FileNum ' creates the file if it doesn't exist    Print #FileNum, TimeValue(Now) & ": " & LogMessage ' write information at the end of the text file    Close #FileNum ' close the fileEnd Sub