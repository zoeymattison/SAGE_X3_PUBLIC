Sub CombineHeaderLinesFormatted_Optimized()

    Dim wsHeader As Worksheet, wsLines As Worksheet, wsOutput As Worksheet, wsReceipts As Worksheet
    Dim lastRowHeader As Long, lastRowLines As Long, lastRowReceipts As Long
    Dim i As Long, j As Long, k As Long
    Dim receiptsDict As Object, linesDict As Object, headerDict As Object
    Dim productCode As String, poNum As String, key As String
    Dim supplierInvoiceKey As String
    Dim rng As Range
    Dim lastRowOutput As Long
    Dim existingData As Variant
    Dim existingLines As Variant
    Dim headerData As Variant
    Dim linesData As Variant
    Dim originalLineQty As Double
    Dim netPrice As Double
    Dim totalReceiptQty As Double
    Dim receiptFound As Boolean
    Dim receiptEntries As Variant, receiptEntry
    Dim receiptQty As Double
    Dim usedQty As Double
    Dim quantityDifference As Double
    Dim taxCode1 As String, taxCode2 As String
    Dim headerColJ As Variant ' Store original calculation mode
    Dim calculationMode As Variant
    Dim headerCE As String 'Store the CE value

    ' --- Improved Error Handling ---
    On Error GoTo ErrorHandler  ' Corrected syntax

    ' --- Screen Updating and Events Off for Performance ---
    Application.ScreenUpdating = False
    calculationMode = Application.Calculation
    Application.Calculation = xlCalculationManual
    Application.EnableEvents = False ' Disable events

    ' Set the worksheets using With statements
    With ThisWorkbook
        Set wsHeader = .Sheets("HEADER")
        Set wsLines = .Sheets("LINES")
        Set wsReceipts = .Sheets("RECEIPTS")
        Set wsOutput = .Sheets("IMPORT")
    End With

    ' Clear existing data
    wsOutput.UsedRange.ClearContents

    ' Find the last rows (efficient method)
    lastRowHeader = wsHeader.Cells(wsHeader.Rows.Count, "A").End(xlUp).Row
    lastRowLines = wsLines.Cells(wsLines.Rows.Count, "A").End(xlUp).Row
    lastRowReceipts = wsReceipts.Cells(wsReceipts.Rows.Count, "A").End(xlUp).Row

    ' --- Build Dictionaries ---

    ' 1. Receipts Dictionary (ProductCode & PO -> Receipt Value)
    Set receiptsDict = CreateObject("Scripting.Dictionary")
    receiptsDict.CompareMode = vbTextCompare ' Case-insensitive comparison

    ' --- Read Data into Arrays (Performance Improvement) ---
    Dim receiptsData As Variant
    receiptsData = wsReceipts.Range("A2:J" & lastRowReceipts).Value ' Read the entire range at once

    For k = 1 To UBound(receiptsData, 1)
        productCode = Trim(CStr(receiptsData(k, 1)))
        productCode = RemoveLeadingZeros(productCode)
        poNum = Trim(CStr(receiptsData(k, 6)))
        key = productCode & "|" & poNum

        If Not receiptsDict.Exists(key) Then
            receiptsDict.Add key, Array(Array(receiptsData(k, 2), receiptsData(k, 3), receiptsData(k, 4), receiptsData(k, 5), receiptsData(k, 9), receiptsData(k, 10)))
        Else
            existingData = receiptsDict.Item(key)
            ReDim Preserve existingData(UBound(existingData) + 1)
            existingData(UBound(existingData)) = Array(receiptsData(k, 2), receiptsData(k, 3), receiptsData(k, 4), receiptsData(k, 5), receiptsData(k, 9), receiptsData(k, 10))
            receiptsDict.Item(key) = existingData
        End If
    Next k

     ' 2. Lines Dictionary (Supplier & Invoice -> Lines Data)
    Set linesDict = CreateObject("Scripting.Dictionary")
    linesDict.CompareMode = vbTextCompare

    ' --- Read Data into Arrays ---
    Dim linesArray As Variant
    linesArray = wsLines.Range("A1:J" & lastRowLines).Value

    For j = 1 To UBound(linesArray, 1)
        supplierInvoiceKey = CleanCell(linesArray(j, 1)) & "|" & CleanCell(linesArray(j, 2))
        If Not linesDict.Exists(supplierInvoiceKey) Then
            linesDict.Add supplierInvoiceKey, Array(Array(linesArray(j, 4), linesArray(j, 5), linesArray(j, 10)))
        Else
            existingLines = linesDict.Item(supplierInvoiceKey)
            ReDim Preserve existingLines(UBound(existingLines) + 1)
            existingLines(UBound(existingLines)) = Array(linesArray(j, 4), linesArray(j, 5), linesArray(j, 10))
            linesDict.Item(supplierInvoiceKey) = existingLines
        End If
    Next j

     ' 3. Header Dictionary (Supplier & Invoice -> Header Data)
    Set headerDict = CreateObject("Scripting.Dictionary")
    headerDict.CompareMode = vbTextCompare

    ' --- Read Data into Arrays ---
    Dim headerArray As Variant
    headerArray = wsHeader.Range("A1:CE" & lastRowHeader).Value 'Read all relevant columns

    For i = 1 To UBound(headerArray, 1)
        headerKey = CleanCell(headerArray(i, 1)) & "|" & CleanCell(headerArray(i, 2))
        headerDict.Add headerKey, Array(CleanCell(headerArray(i, 2)), CleanCell(headerArray(i, 5)), CleanCell(headerArray(i, 53)), CleanCell(headerArray(i, 10)), CleanCell(headerArray(i, 28)), CleanCell(headerArray(i, 83)))
    Next i

    ' --- Process and Output ---
    ' --- Pre-allocate Output Array ---
    Dim outputArray() As Variant
    ReDim outputArray(1 To lastRowHeader * lastRowLines, 1 To 13) ' Pre-size for maximum possible rows
    Dim outputArrayIndex As Long: outputArrayIndex = 1

    For Each headerKey In headerDict.Keys
        headerData = headerDict(headerKey)
        headerCE = headerData(5) ' Store CE value for reuse

        ' Write formatted header information (No CE data on Header)
        outputArray(outputArrayIndex, 1) = "E"
        outputArray(outputArrayIndex, 2) = "INV"
        outputArray(outputArrayIndex, 3) = "V5555"
        outputArray(outputArrayIndex, 4) = "AP"
        outputArray(outputArrayIndex, 5) = headerData(0)
        outputArray(outputArrayIndex, 6) = headerData(1)
        outputArray(outputArrayIndex, 7) = headerData(2)
        outputArray(outputArrayIndex, 8) = headerData(3)
        outputArrayIndex = outputArrayIndex + 1

        'Process Lines using combined dictionary lookup
        If linesDict.Exists(headerKey) Then 'Combined lookup
            linesData = linesDict(headerKey)

            For Each lineEntry In linesData
              If IsArray(lineEntry) Then
                    productCode = Trim(lineEntry(0))
                    If Len(productCode) >= 4 Then
                        If Mid(productCode, 4, 1) = " " Then
                            productCode = Mid(productCode, 5)
                        End If
                    End If
                    originalLineQty = CDbl(lineEntry(1))
                    netPrice = CDbl(lineEntry(2))
                    poValue = CleanCell(headerData(4))

                    If Len(poValue) >= 8 Then
                        poValue = "PO" & Right(poValue, 8)
                    Else
                        poValue = "PO" & poValue
                    End If

                    outputArray(outputArrayIndex, 12) = poValue 'Pre-fill
                    outputArray(outputArrayIndex, 13) = productCode

                    productCode = RemoveLeadingZeros(productCode)
                    lookupKey = productCode & "|" & poValue
                    totalReceiptQty = 0
                    receiptFound = False

                    If receiptsDict.Exists(lookupKey) Then 'Early exit if no receipts
                        receiptFound = True
                        receiptEntries = receiptsDict(lookupKey)
                        headerColJ = headerData(3) 'Get this once

                        For Each receiptEntry In receiptEntries

                            taxCode1 = receiptEntry(4)
                            taxCode2 = receiptEntry(5)

                            If UCase(taxCode1) <> "GST" And headerColJ > 0 Then
                                taxCode1 = "GST"
                            End If

                            If Trim(taxCode2) = "" Then
                                taxCode2 = "NTA"
                            End If

                            receiptQty = receiptEntry(3)

                            If totalReceiptQty + receiptQty <= originalLineQty Then
                                usedQty = receiptQty
                            Else
                                usedQty = Application.WorksheetFunction.Max(0, originalLineQty - totalReceiptQty)
                            End If

                            If usedQty > 0 Then
                                outputArray(outputArrayIndex, 1) = "L"
                                outputArray(outputArrayIndex, 2) = "2"
                                outputArray(outputArrayIndex, 3) = receiptEntry(0)
                                outputArray(outputArrayIndex, 4) = receiptEntry(1)
                                outputArray(outputArrayIndex, 5) = receiptEntry(2)
                                outputArray(outputArrayIndex, 6) = usedQty 'This is where we set the quantity
                                outputArray(outputArrayIndex, 7) = netPrice
                                outputArray(outputArrayIndex, 8) = "=F" & outputArrayIndex & "*G" & outputArrayIndex 'Formula can stay as is
                                outputArray(outputArrayIndex, 9) = taxCode1
                                outputArray(outputArrayIndex, 10) = taxCode2
                                outputArray(outputArrayIndex, 11) = headerCE ' Use pre-stored CE value
                                outputArray(outputArrayIndex, 12) = poValue
                                outputArray(outputArrayIndex, 13) = productCode
                                totalReceiptQty = totalReceiptQty + usedQty
                                outputArrayIndex = outputArrayIndex + 1
                            End If
                        Next receiptEntry
                    Else  'No receipts
                       taxCode1 = "ERROR"
                       taxCode2 = "NTA"
                       headerColJ = headerData(3)

                       If UCase(taxCode1) <> "GST" And headerColJ > 0 Then
                            taxCode1 = "GST"
                       End If
                       If Trim(taxCode2) = "" Then
                            taxCode2 = "NTA"
                       End If

                        outputArray(outputArrayIndex, 1) = "L"
                        outputArray(outputArrayIndex, 2) = "2"
                        outputArray(outputArrayIndex, 3) = "ERROR"
                        outputArray(outputArrayIndex, 4) = "ERROR"
                        outputArray(outputArrayIndex, 5) = "ERROR"
                        outputArray(outputArrayIndex, 6) = "ERROR" ' No receipts, error in Quantity
                        outputArray(outputArrayIndex, 7) = netPrice
                        outputArray(outputArrayIndex, 8) = "=F" & outputArrayIndex & "*G" & outputArrayIndex ' Keep formula
                        outputArray(outputArrayIndex, 9) = taxCode1
                        outputArray(outputArrayIndex, 10) = taxCode2
                        outputArray(outputArrayIndex, 11) = headerCE
                        outputArray(outputArrayIndex, 12) = poValue
                        outputArray(outputArrayIndex, 13) = productCode
                        outputArrayIndex = outputArrayIndex + 1

                    End If  'End of the "If receiptsDict.Exists" check

                    'Check if total receipt quantity < line quantity AFTER processing all receipts
                    If receiptFound And totalReceiptQty < originalLineQty Then
                        'Crucial: If we processed receipts, but they're short, print ERROR
                        outputArray(outputArrayIndex - 1, 6) = "ERROR"
                    End If
                End If
            Next lineEntry
        End If
    Next headerKey

    ' --- Write Output Array to Worksheet ---
    wsOutput.Range("A1").Resize(outputArrayIndex - 1, 13).Value = outputArray

    ' --- Conditional Formatting ---
     lastRowOutput = wsOutput.Cells(wsOutput.Rows.Count, "A").End(xlUp).Row ' Find after writing

    With wsOutput.Range("C1:H" & lastRowOutput)
        .FormatConditions.Delete
        With .FormatConditions.Add(Type:=xlCellValue, Operator:=xlEqual, _
            Formula1:="=""ERROR""")
            .Interior.Color = RGB(255, 204, 204)
        End With
    End With
     ' --- Restore original calculation mode and events ---
    Application.Calculation = calculationMode
    Application.ScreenUpdating = True
    Application.EnableEvents = True ' Re-enable events

    MsgBox "Data combined and formatted successfully!"

Exit Sub

ErrorHandler:
    MsgBox "An error occurred: " & Err.Description & " (Error #" & Err.Number & ")", vbCritical, "Error"
     ' --- Restore original calculation mode in case of error---
    Application.Calculation = calculationMode
    Application.ScreenUpdating = True
    Application.EnableEvents = True ' Re-enable events
End Sub

Function CleanCell(cellValue As Variant) As String
    Dim cleanValue As String

    ' Use TypeName to handle different data types more robustly
    Select Case TypeName(cellValue)
        Case "String"
            cleanValue = cellValue
        Case "Double", "Integer", "Long", "Single", "Date", "Currency"
            cleanValue = CStr(cellValue) ' Convert to string
        Case "Empty", "Null", "Error"
            cleanValue = "" ' Handle empty, null, or error values
        Case Else
            cleanValue = CStr(cellValue) 'Default to CStr
    End Select


    cleanValue = WorksheetFunction.Trim(cleanValue) ' Remove leading/trailing spaces
    cleanValue = Replace(cleanValue, Chr(160), "") ' Remove non-breaking spaces

    Dim i As Long
    For i = 0 To 31
        cleanValue = Replace(cleanValue, Chr(i), "") ' Remove control characters
    Next i

    CleanCell = cleanValue
End Function

Function RemoveLeadingZeros(inputString As String) As String
    Dim result As String
    result = inputString
    ' More efficient way to remove leading zeros.
    Do While Left(result, 1) = "0" And Len(result) > 1
       result = Mid(result, 2)
    Loop
    RemoveLeadingZeros = result
End Function

