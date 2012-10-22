Attribute VB_Name = "Miss_Stats"

'       This module provides variants of the core EXCEL statistical Functions that are designed to ignore missing data
'           and produce a result based on the valid numerical data (or data pairs).  All have the same calling conventions as
'           their EXCEL counterparts.
'
'       The functions are:
'                   MAverage (and a copy called MMean)
'                   MStDev
'                   MMax and MMin
'                   MRank and MMedian and MPercentile
'                   mPearsons,  mIntercept,  mSlope
'            and MPoints which counts the numeric items in the specified range.
'
'      There is also a similar set of functions with the initial letters "MZ" which ignore both missing and zero values
'


Public Function MMean(rr As Range) As Double
Dim sx As Double, cc As Long
    sx = 0: cc = 0
    For Each vv In rr
        If IsNumeric(vv) Then
            sx = sx + vv
            cc = cc + 1
        End If
    Next vv
    If cc > 0 Then MMean = sx / cc Else MMean = CVErr(xlErrNA)
End Function

Public Function MAverage(rr As Range) As Double
    MAverage = MMean(rr)
End Function


Public Function MStDev(rr As Range) As Double
Dim sx As Double, sxx As Double, cc As Long
    sx = 0: sxx = 0: cc = 0
    For Each vv In rr
        If IsNumeric(vv) Then
            sx = sx + vv
            sxx = sxx + vv * vv
            cc = cc + 1
        End If
    Next vv
    If cc > 0 Then MStDev = Sqr((sxx - (sx * sx / cc)) / (cc - 1)) Else MStDev = CVErr(xlErrNA)
End Function

Public Function MMax(rr As Range) As Double
Dim MX As Double, cc As Long, Started As Boolean
    Started = False
    For Each vv In rr
        If IsNumeric(vv) Then
            If Not Started Then
                MMax = vv
                Started = True
            ElseIf vv > MMax Then
                MMax = vv
            End If
        End If
    Next vv
End Function


Public Function MMin(rr As Range) As Double
Dim MN As Double, cc As Long, Started As Boolean
    Started = False
    For Each vv In rr
        If IsNumeric(vv) Then
            If Not Started Then
                MMin = vv
                Started = True
            ElseIf vv < MMin Then
                MMin = vv
            End If
        End If
    Next vv
End Function

Public Function MMedian(rr As Range)
'           VERTICAL data sets ONLY
Dim xx As Variant, yy As Variant, xxt As Variant
Dim kk As Long, kk2 As Long
        '   Temporary store array in yy and copy only numeric values to xx
        rrn = rr.Rows.Count
        If rrn < 1 Then
            MMedian = CVErr(xlErrNA)
        ElseIf rrn = 1 Then
            MMedian = rr.Cells(1, 1)
        Else
         yy = rr.Value: xx = rr.Value    '   xx included here to dimension it
         ii = 0
            For kk = 1 To rrn
                If IsNumeric(yy(kk, 1)) Then
                    ii = ii + 1
                    xx(ii, 1) = yy(kk, 1)
                End If
            Next kk
             If ii = 0 Then
                MMedian = CVErr(xlErrNA)
            Else
               '   Sort array
                For kk = 1 To ii - 1
                   For kk2 = kk + 1 To ii
                        If xx(kk2, 1) < xx(kk, 1) Then
                            xxt = xx(kk, 1)
                            xx(kk, 1) = xx(kk2, 1)
                            xx(kk2, 1) = xxt
                        End If
                    Next kk2
                Next kk
                '   Find median
                mm = Int(ii / 2) + 1
                If Int(ii / 2) = ii / 2 Then '   Even number of points
                    MMedian = (xx(mm, 1) + xx(mm - 1, 1)) / 2
                Else
                    MMedian = xx(mm, 1)
                End If
            End If
        End If
End Function

Public Function MPercentile(rr As Range, pct As Single)
'           VERTICAL data sets ONLY
Dim xx As Variant, yy As Variant, xxt As Variant
Dim kk As Long, kk2 As Long, mm As Single, mmr As Single, mmi As Integer
        '   Temporary store array in yy and copy only numeric values to xx
        rrn = rr.Rows.Count
        If rrn < 1 Then
            MPercentile = CVErr(xlErrNA)        '       No data in range
        ElseIf rrn = 1 Then
            MPercentile = rr.Cells(1, 1)        '       Only one data point
        Else
         yy = rr.Value: xx = rr.Value    '   xx included here to dimension it
         ii = 0
            For kk = 1 To rrn
                If IsNumeric(yy(kk, 1)) Then
                    ii = ii + 1
                    xx(ii, 1) = yy(kk, 1)
                End If
            Next kk
             If ii = 0 Then
                MPercentile = CVErr(xlErrNA)     '      No numeric data
            Else
               '   Sort array
                For kk = 1 To ii - 1
                   For kk2 = kk + 1 To ii
                        If xx(kk2, 1) < xx(kk, 1) Then
                            xxt = xx(kk, 1)
                            xx(kk, 1) = xx(kk2, 1)
                            xx(kk2, 1) = xxt
                        End If
                    Next kk2
                Next kk
                '   Find percentile
                If pct <= 0 Then
                    MPercentile = xx(1, 1)
                ElseIf pct >= 1 Then
                    MPercentile = xx(ii, 1)
                Else
                    mm = (ii + 1) * pct: mmi = Int(mm): mmr = mm - mmi
                    MPercentile = xx(mmi, 1) + mmr * (xx(mmi + 1, 1) - xx(mmi, 1))
                End If
            End If
        End If
End Function
Public Function MPearson(rry As Range, rrx As Range) As Double
'   Returns Pearson R (Not R^2)
Dim sx As Double, sxx As Double, sy As Double, syy As Double, sxy As Double, cc As Long
Dim nrx As Long, nry As Long, ncx As Long, ncy As Long, np As Long, vert As Boolean
Dim xx As Variant, yy As Variant

    sx = 0: sxx = 0: sy = 0: syy = 0: sxy = 0: cc = 0
    nrx = rrx.Rows.Count: nry = rry.Rows.Count: ncx = rrx.Columns.Count: ncy = rry.Columns.Count
    
    If nrx <> nry Or ncx <> ncy Then
        MsgBox "The X & Y ranges are not the same size"
    End If
    If nrx = 1 Then
        If ncx <= 2 Then
            MsgBox "Check the selected ranges"
            Exit Function
        Else
            np = ncx
            vert = True
        End If
    ElseIf ncx = 1 Then
        If nrx <= 2 Then
            MsgBox "Check the selected ranges"
            Exit Function
        Else
            np = nrx
            vert = False
        End If
    Else
        MsgBox "Check the selected ranges -"
    End If
      
    xx = rrx.Value: yy = rry.Value
    
    If Not vert Then
        For ii = 1 To np
            If IsNumeric(xx(ii, 1)) And IsNumeric(yy(ii, 1)) Then
                sx = sx + xx(ii, 1)
                sxx = sxx + xx(ii, 1) ^ 2
                sy = sy + yy(ii, 1)
                syy = syy + yy(ii, 1) ^ 2
                sxy = sxy + xx(ii, 1) * yy(ii, 1)
                cc = cc + 1
            End If
        Next ii
    Else
        For ii = 1 To np
            If IsNumeric(xx(1, ii)) And IsNumeric(yy(1, ii)) Then
                sx = sx + xx(1, ii)
                sxx = sxx + xx(1, ii) ^ 2
                sy = sy + yy(1, ii)
                syy = syy + yy(1, ii) ^ 2
                sxy = sxy + xx(1, ii) * yy(1, ii)
                cc = cc + 1
            End If
        Next ii
    End If
    
    If cc > 0 Then MPearson = (sxy - sx * sy / cc) / Sqr((sxx - sx * sx / cc) * (syy - sy * sy / cc)) Else MPearson = CVErr(xlErrNA)
End Function

Public Function mSlope(rry As Range, rrx As Range) As Double
Dim sx As Double, sxx As Double, sy As Double, syy As Double, sxy As Double, cc As Long
Dim nrx As Long, nry As Long, ncx As Long, ncy As Long, np As Long, vert As Boolean
Dim xx As Variant, yy As Variant

    sx = 0: sxx = 0: sy = 0: syy = 0: sxy = 0: cc = 0
    nrx = rrx.Rows.Count: nry = rry.Rows.Count: ncx = rrx.Columns.Count: ncy = rry.Columns.Count
    
    If nrx <> nry Or ncx <> ncy Then
        MsgBox "The X & Y ranges are not the same size"
    End If
    If nrx = 1 Then
        If ncx <= 2 Then
            MsgBox "Check the selected ranges"
            Exit Function
        Else
            np = ncx
            vert = True
        End If
    ElseIf ncx = 1 Then
        If nrx <= 2 Then
            MsgBox "Check the selected ranges"
            Exit Function
        Else
            np = nrx
            vert = False
        End If
    Else
        MsgBox "Check the selected ranges -"
    End If
      
    xx = rrx.Value: yy = rry.Value
    
    If Not vert Then
        For ii = 1 To np
            If IsNumeric(xx(ii, 1)) And IsNumeric(yy(ii, 1)) Then
                sx = sx + xx(ii, 1)
                sxx = sxx + xx(ii, 1) ^ 2
                sy = sy + yy(ii, 1)
                syy = syy + yy(ii, 1) ^ 2
                sxy = sxy + xx(ii, 1) * yy(ii, 1)
                cc = cc + 1
            End If
        Next ii
    Else
        For ii = 1 To np
            If IsNumeric(xx(1, ii)) And IsNumeric(yy(1, ii)) Then
                sx = sx + xx(1, ii)
                sxx = sxx + xx(1, ii) ^ 2
                sy = sy + yy(1, ii)
                syy = syy + yy(1, ii) ^ 2
                sxy = sxy + xx(1, ii) * yy(1, ii)
                cc = cc + 1
            End If
        Next ii
    End If
    If cc > 0 Then mSlope = (sxy - sx * sy / cc) / (sxx - sx * sx / cc) Else mSlope = CVErr(xlErrNA)
End Function

Public Function mIntercept(rry As Range, rrx As Range) As Double
Dim sx As Double, sxx As Double, sy As Double, syy As Double, sxy As Double, cc As Long
Dim nrx As Long, nry As Long, ncx As Long, ncy As Long, np As Long, vert As Boolean
Dim xx As Variant, yy As Variant

    sx = 0: sxx = 0: sy = 0: syy = 0: sxy = 0: cc = 0
    nrx = rrx.Rows.Count: nry = rry.Rows.Count: ncx = rrx.Columns.Count: ncy = rry.Columns.Count
    
    If nrx <> nry Or ncx <> ncy Then
        MsgBox "The X & Y ranges are not the same size"
    End If
    If nrx = 1 Then
        If ncx <= 2 Then
            MsgBox "Check the selected ranges"
            Exit Function
        Else
            np = ncx
            vert = True
        End If
    ElseIf ncx = 1 Then
        If nrx <= 2 Then
            MsgBox "Check the selected ranges"
            Exit Function
        Else
            np = nrx
            vert = False
        End If
    Else
        MsgBox "Check the selected ranges -"
    End If
      
    xx = rrx.Value: yy = rry.Value
    
    If Not vert Then
        For ii = 1 To np
            If IsNumeric(xx(ii, 1)) And IsNumeric(yy(ii, 1)) Then
                sx = sx + xx(ii, 1)
                sxx = sxx + xx(ii, 1) ^ 2
                sy = sy + yy(ii, 1)
                syy = syy + yy(ii, 1) ^ 2
                sxy = sxy + xx(ii, 1) * yy(ii, 1)
                cc = cc + 1
            End If
        Next ii
    Else
        For ii = 1 To np
            If IsNumeric(xx(1, ii)) And IsNumeric(yy(1, ii)) Then
                sx = sx + xx(1, ii)
                sxx = sxx + xx(1, ii) ^ 2
                sy = sy + yy(1, ii)
                syy = syy + yy(1, ii) ^ 2
                sxy = sxy + xx(1, ii) * yy(1, ii)
                cc = cc + 1
            End If
        Next ii
    End If
    If cc > 0 Then
        Slope = (sxy - sx * sy / cc) / (sxx - sx * sx / cc)
        mIntercept = (sy - sx * Slope) / cc
    Else
        mIntercept = CVErr(xlErrNA)
    End If
End Function

Public Function MRank(xx As Double, rr As Range, Low_ranks_one As Boolean, Split_ties As Boolean) As Variant
ch = 0: cl = 0: ce = 0
For Each vv In rr
    If IsNumeric(vv) Then
        If vv > xx Then
            ch = ch + 1
        ElseIf vv < xx Then
            cl = cl + 1
        Else
            ce = ce + 1
        End If
    End If
Next vv
ct = ch + cl + ce
If ct <= 0 Then
    MRank = CVErr(xlErrNA)
    Else
    If Split_ties Then
        If Low_ranks_one Then MRank = cl + (ce + 1) / 2 Else MRank = ch + (ce + 1) / 2
    Else
        If Low_ranks_one Then MRank = ct - ch - ce + 1 Else MRank = ch + 1
    End If
End If
End Function

Public Function MPoints(rrx As Range, rry As Range) As Double
'  Counts the number of pairs of points that would contribute to a Pearson Correlation etc
'       i.e. rows where both entries are numeric
Dim nrx As Long, nry As Long, ncx As Long, ncy As Long, np As Long, vert As Boolean, cc As Long
Dim xx As Variant, yy As Variant

    nrx = rrx.Rows.Count: nry = rry.Rows.Count: ncx = rrx.Columns.Count: ncy = rry.Columns.Count
    
    If nrx <> nry Or ncx <> ncy Then
        MsgBox "The X & Y ranges are not the same size"
    End If
    If nrx = 1 Then
        If ncx <= 2 Then
            MsgBox "Check the selected ranges"
            Exit Function
        Else
            np = ncx
            vert = True
        End If
    ElseIf ncx = 1 Then
        If nrx <= 2 Then
            MsgBox "Check the selected ranges"
            Exit Function
        Else
            np = nrx
            vert = False
        End If
    Else
        MsgBox "Check the selected ranges -"
    End If
      
    xx = rrx.Value: yy = rry.Value
    
    If Not vert Then
        For ii = 1 To np
            If IsNumeric(xx(ii, 1)) And IsNumeric(yy(ii, 1)) Then
                cc = cc + 1
            End If
        Next ii
    Else
        For ii = 1 To np
            If IsNumeric(xx(1, ii)) And IsNumeric(yy(1, ii)) Then
                cc = cc + 1
            End If
        Next ii
    End If
    MPoints = cc
End Function
'
'_________________________________________________________________________
'       The following set of functions are similar to those above,
'           except that they also ignore zero values in the data set
'_________________________________________________________________________
'
'
Public Function MZMean(rr As Range) As Double
Dim sx As Double, cc As Long
    sx = 0: cc = 0
    For Each vv In rr
        If IsNumeric(vv) Then
        If vv <> 0 Then
            sx = sx + vv
            cc = cc + 1
        End If
        End If
    Next vv
    If cc > 0 Then MZMean = sx / cc Else MZMean = CVErr(xlErrNA)
End Function

Public Function MZAverage(rr As Range) As Double
    MZAverage = MZMean(rr)
End Function


Public Function MZStDev(rr As Range) As Double
Dim sx As Double, sxx As Double, cc As Long
    sx = 0: sxx = 0: cc = 0
    For Each vv In rr
        If IsNumeric(vv) Then
        If vv <> 0 Then
            sx = sx + vv
            sxx = sxx + vv * vv
            cc = cc + 1
        End If
        End If
    Next vv
    If cc > 0 Then MZStDev = Sqr((sxx - (sx * sx / cc)) / (cc - 1)) Else MZStDev = CVErr(xlErrNA)
End Function

Public Function MZMax(rr As Range) As Double
Dim MX As Double, cc As Long, Started As Boolean
    Started = False
    For Each vv In rr
        If IsNumeric(vv) Then
        If vv <> 0 Then
            If Not Started Then
                MZMax = vv
                Started = True
            ElseIf vv > MZMax Then
                MZMax = vv
            End If
        End If
        End If
    Next vv
End Function


Public Function MZMin(rr As Range) As Double
Dim MN As Double, cc As Long, Started As Boolean
    Started = False
    For Each vv In rr
        If IsNumeric(vv) Then
        If vv <> 0 Then
            If Not Started Then
                MZMin = vv
                Started = True
            ElseIf vv < MZMin Then
                MZMin = vv
            End If
        End If
        End If
    Next vv
End Function

Public Function MZMedian(rr As Range)
Dim xx As Variant, yy As Variant, xxt As Variant
Dim kk As Long, kk2 As Long
        '   Temporary store array in yy and copy only numeric values to xx
        rrn = rr.Rows.Count
        If rrn < 1 Then
            MZMedian = CVErr(xlErrNA)
        ElseIf rrn = 1 Then
            MZMedian = rr.Cells(1, 1)
        Else
         yy = rr.Value: xx = rr.Value    '   xx included here to dimension it
         ii = 0
            For kk = 1 To rrn
                If IsNumeric(yy(kk, 1)) Then
                    If yy(kk, 1) <> 0 Then
                        ii = ii + 1
                        xx(ii, 1) = yy(kk, 1)
                    End If
                End If
            Next kk
            If ii = 0 Then
                MZMedian = CVErr(xlErrNA)
            Else
                '   Sort array
                For kk = 1 To ii - 1
                   For kk2 = kk + 1 To ii
                        If xx(kk2, 1) < xx(kk, 1) Then
                            xxt = xx(kk, 1)
                            xx(kk, 1) = xx(kk2, 1)
                            xx(kk2, 1) = xxt
                        End If
                    Next kk2
                Next kk
                '   Find median
                mm = Int(ii / 2) + 1
                If Int(ii / 2) = ii / 2 Then '   Even number of points
                    MZMedian = (xx(mm, 1) + xx(mm - 1, 1)) / 2
                Else
                    MZMedian = xx(mm, 1)
                End If
            End If
        End If
End Function
Public Function MZPercentile(rr As Range, pct As Single)
Dim xx As Variant, yy As Variant, xxt As Variant
Dim kk As Long, kk2 As Long, mm As Single, mmr As Single, mmi As Integer
        '   Temporary store array in yy and copy only numeric values to xx
        rrn = rr.Rows.Count
        If rrn < 1 Then
            MZPercentile = CVErr(xlErrNA)        '       No data in range
        ElseIf rrn = 1 Then
            MZPercentile = rr.Cells(1, 1)        '       Only one data point
        Else
         yy = rr.Value: xx = rr.Value    '   xx included here to dimension it
         ii = 0
            For kk = 1 To rrn
                If IsNumeric(yy(kk, 1)) Then
                If yy(kk, 1) <> 0 Then
                    ii = ii + 1
                    xx(ii, 1) = yy(kk, 1)
                End If
                End If
            Next kk
             If ii = 0 Then
                MZPercentile = CVErr(xlErrNA)     '      No numeric data
            Else
               '   Sort array
                For kk = 1 To ii - 1
                   For kk2 = kk + 1 To ii
                        If xx(kk2, 1) < xx(kk, 1) Then
                            xxt = xx(kk, 1)
                            xx(kk, 1) = xx(kk2, 1)
                            xx(kk2, 1) = xxt
                        End If
                    Next kk2
                Next kk
                '   Find percentile
                If pct <= 0 Then
                    MZPercentile = xx(1, 1)
                ElseIf pct >= 1 Then
                    MZPercentile = xx(ii, 1)
                Else
                    mm = (ii + 1) * pct: mmi = Int(mm): mmr = mm - mmi
                    MZPercentile = xx(mmi, 1) + mmr * (xx(mmi + 1, 1) - xx(mmi, 1))
                End If
            End If
        End If
End Function

Public Function MZPearson(rry As Range, rrx As Range) As Double
'   Returns Pearson R (Not R^2)
Dim sx As Double, sxx As Double, sy As Double, syy As Double, sxy As Double, cc As Long
Dim nrx As Long, nry As Long, ncx As Long, ncy As Long, np As Long, vert As Boolean
Dim xx As Variant, yy As Variant

    sx = 0: sxx = 0: sy = 0: syy = 0: sxy = 0: cc = 0
    nrx = rrx.Rows.Count: nry = rry.Rows.Count: ncx = rrx.Columns.Count: ncy = rry.Columns.Count
    
    If nrx <> nry Or ncx <> ncy Then
        MsgBox "The X & Y ranges are not the same size"
    End If
    If nrx = 1 Then
        If ncx <= 2 Then
            MsgBox "Check the selected ranges"
            Exit Function
        Else
            np = ncx
            vert = True
        End If
    ElseIf ncx = 1 Then
        If nrx <= 2 Then
            MsgBox "Check the selected ranges"
            Exit Function
        Else
            np = nrx
            vert = False
        End If
    Else
        MsgBox "Check the selected ranges -"
    End If
      
    xx = rrx.Value: yy = rry.Value
    
    If Not vert Then
        For ii = 1 To np
            If IsNumeric(xx(ii, 1)) And IsNumeric(yy(ii, 1)) Then
            If xx(ii, 1) <> 0 And yy(ii, 1) <> 0 Then
                sx = sx + xx(ii, 1)
                sxx = sxx + xx(ii, 1) ^ 2
                sy = sy + yy(ii, 1)
                syy = syy + yy(ii, 1) ^ 2
                sxy = sxy + xx(ii, 1) * yy(ii, 1)
                cc = cc + 1
            End If
            End If
        Next ii
    Else
        For ii = 1 To np
            If IsNumeric(xx(1, ii)) And IsNumeric(yy(1, ii)) Then
            If xx(1, ii) <> 0 And yy(1, ii) <> 0 Then
                sx = sx + xx(1, ii)
                sxx = sxx + xx(1, ii) ^ 2
                sy = sy + yy(1, ii)
                syy = syy + yy(1, ii) ^ 2
                sxy = sxy + xx(1, ii) * yy(1, ii)
                cc = cc + 1
            End If
            End If
        Next ii
    End If
    
    If cc > 0 Then MZPearson = (sxy - sx * sy / cc) / Sqr((sxx - sx * sx / cc) * (syy - sy * sy / cc)) Else MZPearson = CVErr(xlErrNA)
End Function

Public Function mZSlope(rry As Range, rrx As Range) As Double
Dim sx As Double, sxx As Double, sy As Double, syy As Double, sxy As Double, cc As Long
Dim nrx As Long, nry As Long, ncx As Long, ncy As Long, np As Long, vert As Boolean
Dim xx As Variant, yy As Variant

    sx = 0: sxx = 0: sy = 0: syy = 0: sxy = 0: cc = 0
    nrx = rrx.Rows.Count: nry = rry.Rows.Count: ncx = rrx.Columns.Count: ncy = rry.Columns.Count
    
    If nrx <> nry Or ncx <> ncy Then
        MsgBox "The X & Y ranges are not the same size"
    End If
    If nrx = 1 Then
        If ncx <= 2 Then
            MsgBox "Check the selected ranges"
            Exit Function
        Else
            np = ncx
            vert = True
        End If
    ElseIf ncx = 1 Then
        If nrx <= 2 Then
            MsgBox "Check the selected ranges"
            Exit Function
        Else
            np = nrx
            vert = False
        End If
    Else
        MsgBox "Check the selected ranges -"
    End If
      
    xx = rrx.Value: yy = rry.Value
    
    If Not vert Then
        For ii = 1 To np
            If IsNumeric(xx(ii, 1)) And IsNumeric(yy(ii, 1)) Then
            If xx(ii, 1) <> 0 And yy(ii, 1) <> 0 Then
                sx = sx + xx(ii, 1)
                sxx = sxx + xx(ii, 1) ^ 2
                sy = sy + yy(ii, 1)
                syy = syy + yy(ii, 1) ^ 2
                sxy = sxy + xx(ii, 1) * yy(ii, 1)
                cc = cc + 1
            End If
            End If
        Next ii
    Else
        For ii = 1 To np
            If IsNumeric(xx(1, ii)) And IsNumeric(yy(1, ii)) Then
            If xx(1, ii) <> 0 And yy(1, ii) <> 0 Then
                sx = sx + xx(1, ii)
                sxx = sxx + xx(1, ii) ^ 2
                sy = sy + yy(1, ii)
                syy = syy + yy(1, ii) ^ 2
                sxy = sxy + xx(1, ii) * yy(1, ii)
                cc = cc + 1
            End If
            End If
        Next ii
    End If
    If cc > 0 Then mZSlope = (sxy - sx * sy / cc) / (sxx - sx * sx / cc) Else mZSlope = CVErr(xlErrNA)
End Function

Public Function mZIntercept(rry As Range, rrx As Range) As Double
Dim sx As Double, sxx As Double, sy As Double, syy As Double, sxy As Double, cc As Long
Dim nrx As Long, nry As Long, ncx As Long, ncy As Long, np As Long, vert As Boolean
Dim xx As Variant, yy As Variant

    sx = 0: sxx = 0: sy = 0: syy = 0: sxy = 0: cc = 0
    nrx = rrx.Rows.Count: nry = rry.Rows.Count: ncx = rrx.Columns.Count: ncy = rry.Columns.Count
    
    If nrx <> nry Or ncx <> ncy Then
        MsgBox "The X & Y ranges are not the same size"
    End If
    If nrx = 1 Then
        If ncx <= 2 Then
            MsgBox "Check the selected ranges"
            Exit Function
        Else
            np = ncx
            vert = True
        End If
    ElseIf ncx = 1 Then
        If nrx <= 2 Then
            MsgBox "Check the selected ranges"
            Exit Function
        Else
            np = nrx
            vert = False
        End If
    Else
        MsgBox "Check the selected ranges -"
    End If
      
    xx = rrx.Value: yy = rry.Value
    
    If Not vert Then
        For ii = 1 To np
            If IsNumeric(xx(ii, 1)) And IsNumeric(yy(ii, 1)) Then
            If xx(ii, 1) <> 0 And yy(ii, 1) <> 0 Then
                sx = sx + xx(ii, 1)
                sxx = sxx + xx(ii, 1) ^ 2
                sy = sy + yy(ii, 1)
                syy = syy + yy(ii, 1) ^ 2
                sxy = sxy + xx(ii, 1) * yy(ii, 1)
                cc = cc + 1
            End If
            End If
        Next ii
    Else
        For ii = 1 To np
            If IsNumeric(xx(1, ii)) And IsNumeric(yy(1, ii)) Then
            If xx(1, ii) <> 0 And yy(1, ii) <> 0 Then
                sx = sx + xx(1, ii)
                sxx = sxx + xx(1, ii) ^ 2
                sy = sy + yy(1, ii)
                syy = syy + yy(1, ii) ^ 2
                sxy = sxy + xx(1, ii) * yy(1, ii)
                cc = cc + 1
            End If
            End If
        Next ii
    End If
    If cc > 0 Then
        Slope = (sxy - sx * sy / cc) / (sxx - sx * sx / cc)
        mZIntercept = (sy - sx * Slope) / cc
    Else
        mZIntercept = CVErr(xlErrNA)
    End If
End Function



Public Function MZRank(xx As Double, rr As Range, Low_ranks_one As Boolean, Split_ties As Boolean) As Variant
ch = 0: cl = 0: ce = 0
For Each vv In rr
    If IsNumeric(vv) Then
    If vv <> 0 Then
        If vv > xx Then
            ch = ch + 1
        ElseIf vv < xx Then
            cl = cl + 1
        Else
            ce = ce + 1
        End If
    End If
    End If
Next vv
ct = ch + cl + ce
If ct <= 0 Then
    MRank = CVErr(xlErrNA)
    Else
    If Split_ties Then
        If Low_ranks_one Then MZRank = cl + (ce + 1) / 2 Else MZRank = ch + (ce + 1) / 2
    Else
        If Low_ranks_one Then MZRank = ct - ch - ce + 1 Else MZRank = ch + 1
    End If
End If
End Function

Public Function MZPoints(rrx As Range, rry As Range) As Double
'  Counts the number of pairs of points that would contribute to a Pearson Correlation etc
'       i.e. rows where both entries are numeric
Dim nrx As Long, nry As Long, ncx As Long, ncy As Long, np As Long, vert As Boolean
Dim xx As Variant, yy As Variant

    nrx = rrx.Rows.Count: nry = rry.Rows.Count: ncx = rrx.Columns.Count: ncy = rry.Columns.Count
    
    If nrx <> nry Or ncx <> ncy Then
        MsgBox "The X & Y ranges are not the same size"
    End If
    If nrx = 1 Then
        If ncx <= 2 Then
            MsgBox "Check the selected ranges"
            Exit Function
        Else
            np = ncx
            vert = True
        End If
    ElseIf ncx = 1 Then
        If nrx <= 2 Then
            MsgBox "Check the selected ranges"
            Exit Function
        Else
            np = nrx
            vert = False
        End If
    Else
        MsgBox "Check the selected ranges -"
    End If
      
    xx = rrx.Value: yy = rry.Value
    
    If Not vert Then
        For ii = 1 To np
            If IsNumeric(xx(ii, 1)) And IsNumeric(yy(ii, 1)) Then
            If xx(ii, 1) <> 0 And yy(ii, 1) <> 0 Then
                cc = cc + 1
            End If
            End If
        Next ii
    Else
        For ii = 1 To np
            If IsNumeric(xx(1, ii)) And IsNumeric(yy(1, ii)) Then
            If xx(1, ii) <> 0 And yy(1, ii) <> 0 Then
                cc = cc + 1
            End If
            End If
        Next ii
    End If
    MZPoints = cc
End Function
