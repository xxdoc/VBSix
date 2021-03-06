Attribute VB_Name = "md5"
Option Explicit

Public Enum Direction
    RollLeft = 1
    RollRight = 2
End Enum
'将二进制序列，填充到符合MD5要求
Public Function FillBin(ByRef source() As Byte) As Byte()
    Dim lngCodeLen As Long
    lngCodeLen = UBound(source) + 1 '获取当前的长度（字节）
    
End Function
'计算一个数字距离某个数字的倍数还差多少
Public Function CalcMiss(ByVal lngNum As Long, ByVal lngUnitNum As Long) As Long
    'lngNum : the number we have
    'lngUnit: the unit number we have
    'example:lngNum=7 lngUnit=2,we need a number that is n Times the value of lngUnit
    Dim fDiv As Double, lngDiv As Long
    If lngNum = lngUnitNum Then
        CalcMiss = 0
        Exit Function
    End If
    fDiv = lngNum / lngUnitNum
    lngDiv = Int(fDiv)
    If IsZs(fDiv) Then
        CalcMiss = 0
    Else
        CalcMiss = (lngDiv + 1) * lngUnitNum - lngNum
    End If
End Function

Public Function IsZs(ByRef value As Variant) As Boolean
    If IsNumeric(value) = False Then
        Err.Raise 11, , "值不是数字"
    End If
    Dim dblValue As Double
    Dim intValue As Long
    dblValue = CDbl(value)
    intValue = Int(value)
    If dblValue - intValue = 0 Then
        IsZs = True
    Else
        IsZs = False
    End If
End Function

Public Function MakeByteFromHaxStr(ByVal strHexCode As String) As Byte()
    'step one:verify string
    Dim i As Long '纯粹用来循环的变量
    Dim lngLength As Long '用来记录长度的变量
    Dim intAsc As Integer
    Dim ret() As Byte   '返回用的数组
    lngLength = Len(strHexCode)
    If lngLength <= 0 Then
        ReDim ret(0)
        Exit Function
    End If
    For i = 1 To lngLength
        intAsc = Asc(Mid(strHexCode, i, 1))
        If ValueIn(intAsc, 48, 57) Or ValueIn(intAsc, 65, 70) Or ValueIn(intAsc, 97, 102) Then
        Else
            Err.Raise 12, , "所提供的字符串非十六进制字符串"
        End If
    Next i
    '开始合成
    '宽度补偿：两个十六进制字符为1个字节
    lngLength = (lngLength + (lngLength Mod 2)) / 2 '十六进制字符串转换为字节数组所需长度
    ReDim ret(lngLength - 1)
    '
End Function

Public Function ValueIn(ByVal value As Long, ByVal lngMin As Long, ByVal lngMax As Long) As Boolean
    If value >= lngMin And value <= lngMax Then
        ValueIn = True
    Else
        ValueIn = False
    End If
End Function

Public Function BitLeft(ByVal inByte As Byte, ByVal steps As Integer, ByVal IsLoop As Boolean) As Byte
    Dim strBin As String
    strBin = ByteToStr(inByte)
    strBin = ShiftStr(strBin, steps, RollLeft, IsLoop)
    inByte = StrToByte(strBin)
    BitLeft = inByte
End Function

'字节数组转十六进制字符串
'创建时：2014年9月19日13:41:07
'创建人：孙瑞
Function ShowBytes(ByRef SourceBytes() As Byte) As String
    Dim strOut As String
    Dim strTmp As String
    Dim i As Long
    For i = 0 To UBound(SourceBytes)
        strTmp = Hex(SourceBytes(i))
        If strOut = "" Then
            strOut = strOut & IIf(Len(strTmp) > 1, strTmp, "0" & strTmp)
        Else
            strOut = strOut & " " & IIf(Len(strTmp) > 1, strTmp, "0" & strTmp)
        End If
    Next i
    ShowBytes = strOut
End Function


'将字节转换为二进制形式的字符串
'创建时：2014年9月19日13:35:36
'创建人：孙瑞
Public Function ByteToStr(ByVal inByte As Byte) As String
    Dim BinStr As String
    Dim i As Integer
    For i = 7 To 0 Step -1
        If (inByte And 2 ^ i) > 0 Then
            BinStr = BinStr & "1"
        Else
            BinStr = BinStr & "0"
        End If
    Next i
    ByteToStr = BinStr
End Function
'将字符串按照给定滚动字数，方向，是否轮回滚动等选项进行滚动，输出滚动后的结果。
'创建时：2014年9月19日13:29:33
'创建者：孙瑞
Public Function ShiftStr(ByVal strSource As String, ByVal lngSteps As Long, ByVal intDirection As Direction, ByVal IsLoop As Boolean, Optional ByVal AutoInsert As String = "0") As String
    Dim strRet As String
    Dim absSteps As Long
    Dim lngStrLen As Long
    
    lngStrLen = Len(strSource)
    absSteps = lngSteps Mod lngStrLen
    
    If intDirection = Direction.RollLeft Then
        '向左移
        If IsLoop Then
            strRet = Mid(strSource, absSteps + 1) & Mid(strSource, 1, absSteps)
            ShiftStr = strRet
            Exit Function
        Else
            If lngSteps >= lngStrLen Then
                strRet = String(lngStrLen, AutoInsert)
                ShiftStr = strRet
                Exit Function
            Else
                strRet = Mid(strSource, absSteps + 1) + String(absSteps, AutoInsert)
                ShiftStr = strRet
                Exit Function
            End If
        End If
    ElseIf intDirection = Direction.RollRight Then
        '向右移
        If IsLoop Then
            strRet = Mid(strSource, lngStrLen - absSteps + 1) & Mid(strSource, 1, lngStrLen - absSteps)
            ShiftStr = strRet
            Exit Function
        Else
            If lngSteps >= lngStrLen Then
                strRet = String(lngStrLen, AutoInsert)
                ShiftStr = strRet
                Exit Function
            Else
                strRet = String(absSteps, AutoInsert) & Mid(strSource, 1, lngStrLen - absSteps)
                ShiftStr = strRet
                Exit Function
            End If
        End If
    End If
End Function
'字符串数组转Byte
'创建时：2014年9月19日14:02:00
'创建人：孙瑞
Public Function StrToByte(ByVal strBin As String) As Byte
    Dim i As Integer
    Dim intStrLen As Integer
    Dim byteRet As Byte
    intStrLen = Len(strBin)
    byteRet = 0
    If intStrLen > 8 Then
        Err.Raise 113, , "字符串位数长度超过8位"
    End If
    For i = 1 To intStrLen
        If Mid(strBin, i, 1) = "1" Or Mid(strBin, i, 1) = "0" Then
        
        Else
            Err.Raise 114, , "字符串不是有效二进制类型"
        End If
    Next i
    For i = 1 To intStrLen
        byteRet = byteRet + 2 ^ (i - 1) * Int(Mid(strBin, intStrLen - i + 1, 1))
    Next i
    StrToByte = byteRet
End Function
'计算两数求余的值，并且返回正数余数
'创建时：2014年9月20日22:46:35
'创建人：孙瑞
Public Function MyMod(ByVal intValue As Integer, ByVal intMod As Integer) As Integer
    If intValue >= 0 Then
        MyMod = intValue Mod intMod
    Else
        MyMod = (intValue Mod intMod) + intMod
    End If
End Function


