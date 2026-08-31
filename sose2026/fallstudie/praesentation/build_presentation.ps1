param(
    [string]$TemplatePath = (Join-Path $PSScriptRoot '..\..\..\templates\Grenzebach_PowerPoint_Master_DE.potx'),
    [string]$OutputPath = (Join-Path $PSScriptRoot 'ROSI_Fallstudie_Praesentation.pptx')
)

$ErrorActionPreference = 'Stop'

# PowerPoint constants used explicitly so the build remains dependency-free.
$msoFalse = 0
$msoTrue = -1
$msoTextOrientationHorizontal = 1
$msoShapeRectangle = 1
$msoConnectorStraight = 1
$msoArrowheadTriangle = 3
$ppSaveAsOpenXMLPresentation = 24
$fadeEffect = 3849
$footerText = 'ROSI · Verfügbarkeit und Fehlertoleranz'

# Corporate red/black/white and restrained neutral blue-gray tones.
$C_RED = [int]0x241BED
$C_BLACK = [int]0x000000
$C_WHITE = [int]0xFFFFFF
$C_INK = [int]0x322D28
$C_TEXT = [int]0x635E58
$C_SLATE = [int]0x887D6E
$C_BLUEGRAY = [int]0xB8A591
$C_NAVY = [int]0x634A27
$C_BLUE = [int]0xBF6217
$C_LIGHTBLUE = [int]0xF7F3EE
$C_LIGHTGRAY = [int]0xF5F4F2
$C_GRID = [int]0xE3DED7
$C_LIGHTRED = [int]0xECEAFB

function Get-Layout([object]$Presentation, [string]$Name) {
    foreach ($layout in $Presentation.Designs.Item(1).SlideMaster.CustomLayouts) {
        if ($layout.Name -eq $Name) { return $layout }
    }
    throw "Layout nicht gefunden: $Name"
}

function Get-PlaceholderType([object]$Shape) {
    try { return [int]$Shape.PlaceholderFormat.Type } catch { return 0 }
}

function Get-Placeholders([object]$Slide, [int]$Type = 0) {
    @($Slide.Shapes | Where-Object {
        $placeholderType = Get-PlaceholderType $_
        ($placeholderType -ne 0) -and (($Type -eq 0) -or ($placeholderType -eq $Type))
    } | Sort-Object Top, Left)
}

function Set-TextStyle {
    param(
        [object]$Shape,
        [string]$Text,
        [double]$FontSize = 16,
        [int]$Color = $C_TEXT,
        [bool]$Bold = $false,
        [int]$Alignment = 1,
        [int]$VerticalAnchor = 1,
        [double]$Margin = 0.8
    )
    $Shape.TextFrame.TextRange.Text = $Text
    $Shape.TextFrame.WordWrap = $msoTrue
    $Shape.TextFrame.AutoSize = 0
    $Shape.TextFrame.MarginLeft = $Margin
    $Shape.TextFrame.MarginRight = $Margin
    $Shape.TextFrame.MarginTop = $Margin
    $Shape.TextFrame.MarginBottom = $Margin
    try { $Shape.TextFrame.TextRange.ParagraphFormat.Bullet.Visible = $msoFalse } catch {}
    try { $Shape.TextFrame2.TextRange.ParagraphFormat.Bullet.Visible = $msoFalse } catch {}
    $Shape.TextFrame.TextRange.ParagraphFormat.Alignment = $Alignment
    $Shape.TextFrame.TextRange.Font.Name = 'Arial'
    $Shape.TextFrame.TextRange.Font.Size = $FontSize
    $Shape.TextFrame.TextRange.Font.Bold = if ($Bold) { $msoTrue } else { $msoFalse }
    $Shape.TextFrame.TextRange.Font.Color.RGB = $Color
    try { $Shape.TextFrame2.VerticalAnchor = $VerticalAnchor } catch {}
    try { $Shape.Shadow.Visible = $msoFalse } catch {}
}

function Set-PlaceholderText {
    param(
        [object]$Shape,
        [string]$Text,
        [double]$FontSize = 16,
        [int]$Color = $C_TEXT,
        [bool]$Bold = $false,
        [int]$Alignment = 1
    )
    Set-TextStyle -Shape $Shape -Text $Text -FontSize $FontSize -Color $Color -Bold $Bold -Alignment $Alignment -VerticalAnchor 1 -Margin 0.5
}

function Set-Transition([object]$Slide) {
    $Slide.SlideShowTransition.EntryEffect = $fadeEffect
    $Slide.SlideShowTransition.Duration = 0.4
}

function Set-SpeakerNotes([object]$Slide, [string]$Text) {
    foreach ($shape in $Slide.NotesPage.Shapes) {
        try {
            if ($shape.PlaceholderFormat.Type -eq 2) {
                $shape.TextFrame.TextRange.Text = $Text.Trim()
                return
            }
        } catch {}
    }
    throw "Notizen-Platzhalter auf Folie $($Slide.SlideIndex) nicht gefunden."
}

function Set-TitleSlide([object]$Slide, [string]$Title, [string]$Subtitle) {
    $body = Get-Placeholders -Slide $Slide -Type 2
    if ($body.Count -lt 2) { throw "Title-Layout auf Folie $($Slide.SlideIndex) besitzt nicht zwei Textplatzhalter." }
    Set-PlaceholderText -Shape $body[0] -Text $Title -FontSize 18 -Color $C_INK -Bold $true
    Set-PlaceholderText -Shape $body[1] -Text $Subtitle -FontSize 10.5 -Color $C_TEXT
}

function Set-ContentHeader([object]$Slide, [string]$Title, [string]$Source, [string]$Kicker) {
    $titleShape = Get-Placeholders -Slide $Slide -Type 1 | Select-Object -First 1
    if (-not $titleShape) { throw "Titelplatzhalter auf Folie $($Slide.SlideIndex) fehlt." }
    Set-PlaceholderText -Shape $titleShape -Text $Title -FontSize 22 -Color $C_INK -Bold $true
    $body = Get-Placeholders -Slide $Slide -Type 2
    $subtitle = @($body | Where-Object { $_.Top -lt 90 }) | Select-Object -First 1
    $sourceShape = @($body | Where-Object { $_.Top -gt 480 }) | Select-Object -First 1
    if ($sourceShape) {
        if ($subtitle) { Set-PlaceholderText -Shape $subtitle -Text $Kicker -FontSize 9 -Color $C_SLATE -Bold $true }
        Set-PlaceholderText -Shape $sourceShape -Text "Quelle: $Source" -FontSize 8 -Color $C_TEXT
    } elseif ($subtitle) {
        # The 1Picture_1Text master has no separate source placeholder. Keep
        # the source in its native subtitle placeholder instead of adding a
        # fake source textbox.
        Set-PlaceholderText -Shape $subtitle -Text "$Kicker · Quelle: $Source" -FontSize 8 -Color $C_SLATE -Bold $true
    }
    # A single fine red rule is the only accent in the content header.
    Add-Line -Slide $Slide -X1 28.3 -Y1 83.5 -X2 930 -Y2 83.5 -Color $C_RED -Weight 1.5 | Out-Null
}

function Clear-ContentPlaceholders([object]$Slide) {
    foreach ($shape in Get-Placeholders -Slide $Slide -Type 2) {
        if ($shape.Top -ge 90 -and $shape.Top -lt 480) { Set-PlaceholderText -Shape $shape -Text '' -FontSize 16 }
    }
}

function Remove-VisualPlaceholders([object]$Slide) {
    # Picture/content placeholders are not used: the visual is built with
    # native shapes, except for the single original Case 2 measurement image.
    $visuals = @($Slide.Shapes | Where-Object {
        $placeholderType = Get-PlaceholderType $_
        $placeholderType -eq 7 -or $placeholderType -eq 18
    })
    foreach ($shape in $visuals) { $shape.Delete() }
}

function Use-BodyPlaceholder {
    param(
        [object]$Slide,
        [string]$Text,
        [double]$X = 35,
        [double]$Y = 105,
        [double]$Width = 888,
        [double]$Height = 22,
        [double]$FontSize = 13,
        [int]$Color = $C_INK,
        [bool]$Bold = $true,
        [int]$Alignment = 2
    )
    $body = @((Get-Placeholders -Slide $Slide -Type 2) | Where-Object { $_.Top -ge 90 -and $_.Top -lt 480 })
    if ($body.Count -eq 0) { throw "Folie $($Slide.SlideIndex) besitzt keinen nativen Body-Placeholder." }
    $shape = $body[0]
    $shape.Left = $X
    $shape.Top = $Y
    $shape.Width = $Width
    $shape.Height = $Height
    Set-PlaceholderText -Shape $shape -Text $Text -FontSize $FontSize -Color $Color -Bold $Bold -Alignment $Alignment
    for ($i = 1; $i -lt $body.Count; $i++) { Set-PlaceholderText -Shape $body[$i] -Text '' -FontSize 16 }
    return $shape
}

function Enable-NativeFooter([object]$Slide) {
    $headers = $Slide.HeadersFooters
    $headers.DateAndTime.Visible = $msoTrue
    $headers.Footer.Visible = $msoTrue
    $headers.SlideNumber.Visible = $msoTrue
    try { $headers.Footer.Text = $footerText } catch {}
    try { $headers.DateAndTime.UseFormat = $msoTrue } catch {}
}

function Add-TextBox {
    param(
        [object]$Slide,
        [double]$X,
        [double]$Y,
        [double]$Width,
        [double]$Height,
        [string]$Text,
        [double]$FontSize = 16,
        [int]$Color = $C_TEXT,
        [bool]$Bold = $false,
        [int]$Alignment = 1,
        [int]$VerticalAnchor = 1,
        [string]$Name = ''
    )
    $shape = $Slide.Shapes.AddTextbox($msoTextOrientationHorizontal, $X, $Y, $Width, $Height)
    if ($Name) { try { $shape.Name = $Name } catch {} }
    $shape.Fill.Visible = $msoFalse
    $shape.Line.Visible = $msoFalse
    Set-TextStyle -Shape $shape -Text $Text -FontSize $FontSize -Color $Color -Bold $Bold -Alignment $Alignment -VerticalAnchor $VerticalAnchor -Margin 0.8
    return $shape
}

function Add-Rect {
    param(
        [object]$Slide,
        [double]$X,
        [double]$Y,
        [double]$Width,
        [double]$Height,
        [int]$Fill = $C_WHITE,
        [int]$Line = $C_GRID,
        [double]$Weight = 1,
        [string]$Name = ''
    )
    $shape = $Slide.Shapes.AddShape($msoShapeRectangle, $X, $Y, $Width, $Height)
    if ($Name) { try { $shape.Name = $Name } catch {} }
    $shape.Fill.Solid()
    $shape.Fill.ForeColor.RGB = $Fill
    $shape.Line.Visible = $msoTrue
    $shape.Line.ForeColor.RGB = $Line
    $shape.Line.Weight = $Weight
    try { $shape.Shadow.Visible = $msoFalse } catch {}
    return $shape
}

function Add-Line {
    param(
        [object]$Slide,
        [double]$X1,
        [double]$Y1,
        [double]$X2,
        [double]$Y2,
        [int]$Color = $C_GRID,
        [double]$Weight = 1,
        [bool]$Arrow = $false,
        [string]$Name = ''
    )
    $shape = $Slide.Shapes.AddConnector($msoConnectorStraight, $X1, $Y1, $X2, $Y2)
    if ($Name) { try { $shape.Name = $Name } catch {} }
    $shape.Line.ForeColor.RGB = $Color
    $shape.Line.Weight = $Weight
    if ($Arrow) { $shape.Line.EndArrowheadStyle = $msoArrowheadTriangle }
    try { $shape.Shadow.Visible = $msoFalse } catch {}
    return $shape
}

function Set-CellText {
    param(
        [object]$Cell,
        [string]$Text,
        [double]$FontSize = 10.5,
        [int]$Color = $C_TEXT,
        [bool]$Bold = $false,
        [int]$Alignment = 1
    )
    $shape = $Cell.Shape
    $shape.TextFrame.TextRange.Text = $Text
    try { $shape.TextFrame.WordWrap = $msoTrue } catch {}
    try { $shape.TextFrame.AutoSize = 0 } catch {}
    try { $shape.TextFrame.MarginLeft = 4 } catch {}
    try { $shape.TextFrame.MarginRight = 4 } catch {}
    try { $shape.TextFrame.MarginTop = 2 } catch {}
    try { $shape.TextFrame.MarginBottom = 2 } catch {}
    try { $shape.TextFrame.TextRange.ParagraphFormat.Bullet.Visible = $msoFalse } catch {}
    $shape.TextFrame.TextRange.ParagraphFormat.Alignment = $Alignment
    $shape.TextFrame.TextRange.Font.Name = 'Arial'
    $shape.TextFrame.TextRange.Font.Size = $FontSize
    $shape.TextFrame.TextRange.Font.Bold = if ($Bold) { $msoTrue } else { $msoFalse }
    $shape.TextFrame.TextRange.Font.Color.RGB = $Color
    try { $shape.TextFrame2.VerticalAnchor = 3 } catch {}
    try { $shape.Fill.Solid(); $shape.Fill.ForeColor.RGB = $C_WHITE } catch {}
    try { $shape.Line.Visible = $msoTrue; $shape.Line.ForeColor.RGB = $C_GRID; $shape.Line.Weight = 0.75 } catch {}
    try { $shape.Shadow.Visible = $msoFalse } catch {}
}

function Add-NativeTable {
    param(
        [object]$Slide,
        [double]$X,
        [double]$Y,
        [double]$Width,
        [double]$Height,
        [string[][]]$Rows,
        [double[]]$ColumnWidths = @(),
        [double]$BodyFont = 10.5,
        [string]$Name = ''
    )
    $rowCount = $Rows.Count
    $columnCount = $Rows[0].Count
    $tableShape = $Slide.Shapes.AddTable($rowCount, $columnCount, $X, $Y, $Width, $Height)
    if ($Name) { try { $tableShape.Name = $Name } catch {} }
    $table = $tableShape.Table
    if ($ColumnWidths.Count -eq $columnCount) {
        for ($column = 1; $column -le $columnCount; $column++) { $table.Columns.Item($column).Width = $ColumnWidths[$column - 1] }
    }
    $rowHeight = $Height / $rowCount
    for ($row = 1; $row -le $rowCount; $row++) {
        $table.Rows.Item($row).Height = $rowHeight
        for ($column = 1; $column -le $columnCount; $column++) {
            $cell = $table.Cell($row, $column)
            $isHeader = $row -eq 1
            Set-CellText -Cell $cell -Text ([string]$Rows[$row - 1][$column - 1]) -FontSize $(if ($isHeader) { 10 } else { $BodyFont }) -Color $(if ($isHeader) { $C_WHITE } else { $C_TEXT }) -Bold $isHeader
            if ($isHeader) {
                $cell.Shape.Fill.ForeColor.RGB = $C_INK
                try { $cell.Shape.Line.ForeColor.RGB = $C_WHITE } catch {}
            } elseif (($row % 2) -eq 0) {
                $cell.Shape.Fill.ForeColor.RGB = $C_LIGHTGRAY
            }
        }
    }
    try { $tableShape.Shadow.Visible = $msoFalse } catch {}
    return $tableShape
}

function Add-Stat {
    param([object]$Slide,[double]$X,[double]$Width,[string]$Value,[string]$Label,[int]$Color=$C_INK)
    Add-TextBox -Slide $Slide -X $X -Y 105 -Width $Width -Height 30 -Text $Value -FontSize 23 -Color $Color -Bold $true -Name "StatValue_$X" | Out-Null
    Add-TextBox -Slide $Slide -X $X -Y 137 -Width $Width -Height 19 -Text $Label -FontSize 9.5 -Color $C_SLATE -Bold $true -Name "StatLabel_$X" | Out-Null
}

if (-not (Test-Path -LiteralPath $TemplatePath)) { throw "Firmentemplate fehlt: $TemplatePath" }
$uv = Get-Command uv -ErrorAction SilentlyContinue
$python = Get-Command python -ErrorAction SilentlyContinue
$renderScript = Join-Path $PSScriptRoot 'render_diagrams.py'
if ($uv) {
    & $uv.Source run --with pymupdf python $renderScript
} elseif ($python) {
    & $python.Source $renderScript
} else {
    throw 'Python/uv wird zur mechanischen PDF-Konvertierung benötigt.'
}
if ($LASTEXITCODE -ne 0) { throw "Bildkonvertierung fehlgeschlagen (ExitCode=$LASTEXITCODE)." }

$imagePath = Join-Path $PSScriptRoot 'diagrams\case2_image_out_usage.png'
if (-not (Test-Path -LiteralPath $imagePath)) { throw "Bildasset fehlt: $imagePath" }
$outputDirectory = Split-Path -Parent $OutputPath
if (-not (Test-Path -LiteralPath $outputDirectory)) { New-Item -ItemType Directory -Path $outputDirectory | Out-Null }
if (Test-Path -LiteralPath $OutputPath) { [IO.File]::Delete($OutputPath) }

$powerPoint = $null
$templateReference = $null
$presentation = $null
try {
    $powerPoint = New-Object -ComObject PowerPoint.Application
    $powerPoint.Visible = $msoTrue
    $templateReference = $powerPoint.Presentations.Open((Resolve-Path -LiteralPath $TemplatePath).Path, $msoFalse, $msoTrue, $msoFalse)
    $templateWidth = [double]$templateReference.PageSetup.SlideWidth
    $templateHeight = [double]$templateReference.PageSetup.SlideHeight
    $templateReference.Close()
    $templateReference = $null
    $presentation = $powerPoint.Presentations.Add()
    $presentation.ApplyTemplate((Resolve-Path -LiteralPath $TemplatePath).Path)
    $presentation.PageSetup.SlideWidth = $templateWidth
    $presentation.PageSetup.SlideHeight = $templateHeight
    $masterHeaders = $presentation.Designs.Item(1).SlideMaster.HeadersFooters
    try { $masterHeaders.DisplayOnTitleSlide = $msoTrue } catch {}
    try { $masterHeaders.Footer.Text = $footerText } catch {}

    # 1 — native Grenzebach title background.
    $slide = $presentation.Slides.AddSlide(1, (Get-Layout $presentation 'Title'))
    Set-TitleSlide -Slide $slide -Title 'Analyse der Verfügbarkeit, Ausfalltoleranz und Konsistenz des KI-basierten Multisensorik-ROSI-Systems' -Subtitle 'Empirische Fault-Injection-Analyse auf Prozess- und Betriebssystemebene · Luca Michael Schmidt · September 2026'
    Set-Transition $slide
    Set-SpeakerNotes -Slide $slide -Text @'
Sprechzeit: 0:50
Quellenhinweis: Avizienis et al., Basic Concepts and Taxonomy of Dependable and Secure Computing, 2004; eigene Fallstudie.

Guten Tag. Diese Fallstudie analysiert die Verfügbarkeit, Ausfalltoleranz und Konsistenz des KI-basierten Multisensorik-ROSI-Systems. ROSI steht für Realtime Optical Surface Inspection und prüft Materialoberflächen inline. Im Zentrum steht nicht die Güte des KI-Modells, sondern die Frage, wie sich das Gesamtsystem verhält, wenn eine einzelne technische Komponente ausfällt. Die Untersuchung verbindet deshalb wissenschaftliche Begriffe der Dependability mit fünf gezielten Fault-Injection-Tests. Ich trenne im Vortrag zwischen direkt gemessenen Ergebnissen, analytisch abgeleiteten Produktionsrisiken und einer Hypothese, die im Test nicht bestätigt wurde. Zuerst ordne ich den 24/7-Kontext und die Architektur ein. Danach folgen Methodik und Fälle. Am Ende verdichte ich die Befunde zu konkreten Schutzschichten für Prozess-, Speicher-, Queue- und Datenbankgrenzen.
'@

    # 2 — context and research question, native flow.
    $slide = $presentation.Slides.AddSlide($presentation.Slides.Count + 1, (Get-Layout $presentation '1Picture_1Text'))
    Set-ContentHeader -Slide $slide -Title 'Ausgangslage und Forschungsfrage' -Source 'Eigene Ausarbeitung, Kap. 1; Avizienis et al. (2004)' -Kicker '01 · KONTEXT'
    Remove-VisualPlaceholders -Slide $slide
    Use-BodyPlaceholder -Slide $slide -Text "24/7-Inspektion braucht`nsichtbare Fehlergrenzen" -X 35 -Y 105 -Width 570 -Height 58 -FontSize 24 -Color $C_INK -Bold $true -Alignment 1 | Out-Null
    Add-Line -Slide $slide -X1 35 -Y1 181 -X2 923 -Y2 181 -Color $C_GRID -Weight 1 | Out-Null
    $contextBoxes = @(
        @{ X = 45; Head = 'MATERIALFLUSS'; Body = 'kontinuierlich'; Fill = $C_LIGHTGRAY },
        @{ X = 355; Head = 'ROSI'; Body = 'Bild + Messwert'; Fill = $C_LIGHTBLUE },
        @{ X = 665; Head = 'BETRIEBSFOLGE'; Body = 'Ergebnis oder Stillstand'; Fill = $C_LIGHTGRAY }
    )
    foreach ($item in $contextBoxes) {
        Add-Rect -Slide $slide -X $item.X -Y 235 -Width 245 -Height 92 -Fill $item.Fill -Line $C_BLUEGRAY -Weight 1 -Name "Context_$($item.Head)" | Out-Null
        Add-TextBox -Slide $slide -X ($item.X + 12) -Y 248 -Width 220 -Height 18 -Text $item.Head -FontSize 9.5 -Color $C_SLATE -Bold $true | Out-Null
        Add-TextBox -Slide $slide -X ($item.X + 12) -Y 274 -Width 220 -Height 31 -Text $item.Body -FontSize 16 -Color $C_INK -Bold $true | Out-Null
    }
    Add-Line -Slide $slide -X1 290 -Y1 281 -X2 350 -Y2 281 -Color $C_NAVY -Weight 1.4 -Arrow $true | Out-Null
    Add-Line -Slide $slide -X1 600 -Y1 281 -X2 660 -Y2 281 -Color $C_NAVY -Weight 1.4 -Arrow $true | Out-Null
    Add-Line -Slide $slide -X1 35 -Y1 371 -X2 923 -Y2 371 -Color $C_RED -Weight 1.5 | Out-Null
    Add-TextBox -Slide $slide -X 35 -Y 386 -Width 110 -Height 20 -Text 'FORSCHUNGSFRAGE' -FontSize 9.5 -Color $C_RED -Bold $true | Out-Null
    Add-TextBox -Slide $slide -X 170 -Y 382 -Width 735 -Height 44 -Text 'Wie erkennt und begrenzt ROSI lokale Fehler, bevor sie den Inspektionspfad erreichen?' -FontSize 18 -Color $C_INK -Bold $true -Name 'ResearchQuestion' | Out-Null
    Set-Transition $slide
    Set-SpeakerNotes -Slide $slide -Text @'
Sprechzeit: 0:55
Quellenhinweis: Eigene Ausarbeitung, Kapitel 1; Avizienis et al., Basic Concepts and Taxonomy of Dependable and Secure Computing, 2004.

ROSI arbeitet als inline eingesetztes Bildverarbeitungssystem an einer Produktionslinie. Der Materialfluss ist kontinuierlich, während eine permanente manuelle Beobachtung gerade nicht vorausgesetzt werden kann. Ein technischer Fehler ist daher nicht nur ein lokales Softwareproblem. Er kann dazu führen, dass Inspektionsergebnisse ausbleiben oder dass die Linie auf einen definierten Zustand gebracht werden muss. Die Fallstudie grenzt ihren Gegenstand bewusst ein: Bewertet werden Verfügbarkeit, Fehlertoleranz, Ressourcenverhalten und Persistenz auf Prozess- und Betriebssystemebene. Aussagen über Defektklassen oder die Modellgüte sind nicht Teil der Untersuchung. Die Abbildung reduziert den Kontext auf Materialfluss, ROSI-Verarbeitung und die mögliche Betriebsfolge. Daraus ergibt sich die Forschungsfrage: Erkennt und begrenzt ROSI lokale Fehler rechtzeitig, oder propagieren diese bis in die gesamte Inspektionslinie?
'@

    # 3 — native architecture and reference metrics.
    $slide = $presentation.Slides.AddSlide($presentation.Slides.Count + 1, (Get-Layout $presentation 'Big object + 1 text box'))
    Set-ContentHeader -Slide $slide -Title 'Systemarchitektur und Referenzbetrieb' -Source 'Eigene Ausarbeitung, Kap. 2; Python shared_memory (Python 3 Docs)' -Kicker '01 · ARCHITEKTUR'
    Remove-VisualPlaceholders -Slide $slide
    Add-Stat -Slide $slide -X 45 -Width 230 -Value '1,74 / s' -Label 'INSPEKTIONEN IM REFERENZBETRIEB'
    Add-Stat -Slide $slide -X 360 -Width 230 -Value '383 ms' -Label 'MITTLERE PIPELINE-DAUER'
    Add-Stat -Slide $slide -X 675 -Width 230 -Value '12' -Label 'WORKER IN SECHS SCHRITTEN'
    Add-Line -Slide $slide -X1 325 -Y1 105 -X2 325 -Y2 153 -Color $C_GRID -Weight 1 | Out-Null
    Add-Line -Slide $slide -X1 640 -Y1 105 -X2 640 -Y2 153 -Color $C_GRID -Weight 1 | Out-Null
    Use-BodyPlaceholder -Slide $slide -Text 'PROZESSE UND GEMEINSAME RESSOURCEN' -X 35 -Y 166 -Width 400 -Height 18 -FontSize 9.5 -Color $C_SLATE -Bold $true -Alignment 1 | Out-Null
    $serviceNames = @('Frame-Grabber','Pipeline-Manager','Inspection DataHandler','Logger')
    $serviceX = @(35, 260, 485, 710)
    for ($i = 0; $i -lt 4; $i++) {
        $line = if ($i -eq 1) { $C_RED } else { $C_BLUEGRAY }
        $fill = if ($i -eq 1) { $C_LIGHTRED } else { $C_LIGHTGRAY }
        Add-Rect -Slide $slide -X $serviceX[$i] -Y 198 -Width 190 -Height 65 -Fill $fill -Line $line -Weight 1.2 -Name "Service_$i" | Out-Null
        Add-TextBox -Slide $slide -X ($serviceX[$i] + 8) -Y 210 -Width 174 -Height 40 -Text $serviceNames[$i] -FontSize 14 -Color $C_INK -Bold $true -Alignment 2 | Out-Null
    }
    Add-TextBox -Slide $slide -X 38 -Y 274 -Width 170 -Height 18 -Text 'keine Top-Level-Reaktion' -FontSize 9 -Color $C_TEXT -Alignment 2 | Out-Null
    Add-TextBox -Slide $slide -X 263 -Y 274 -Width 184 -Height 18 -Text '1-s-Poll · Supervisor' -FontSize 9 -Color $C_RED -Bold $true -Alignment 2 | Out-Null
    Add-TextBox -Slide $slide -X 488 -Y 274 -Width 184 -Height 18 -Text 'keine Top-Level-Reaktion' -FontSize 9 -Color $C_TEXT -Alignment 2 | Out-Null
    Add-TextBox -Slide $slide -X 713 -Y 274 -Width 184 -Height 18 -Text 'zentrale Log-Queue' -FontSize 9 -Color $C_TEXT -Alignment 2 | Out-Null
    Add-Line -Slide $slide -X1 225 -Y1 230 -X2 255 -Y2 230 -Color $C_NAVY -Weight 1 -Arrow $true | Out-Null
    Add-Line -Slide $slide -X1 450 -Y1 230 -X2 480 -Y2 230 -Color $C_NAVY -Weight 1 -Arrow $true | Out-Null
    Add-Line -Slide $slide -X1 675 -Y1 230 -X2 705 -Y2 230 -Color $C_NAVY -Weight 1 -Arrow $true | Out-Null
    Add-TextBox -Slide $slide -X 35 -Y 320 -Width 220 -Height 18 -Text 'main.py steuert' -FontSize 11 -Color $C_SLATE -Bold $true | Out-Null
    Add-Line -Slide $slide -X1 145 -Y1 338 -X2 145 -Y2 350 -Color $C_RED -Weight 1.3 -Arrow $true | Out-Null
    Add-Rect -Slide $slide -X 180 -Y 343 -Width 600 -Height 48 -Fill $C_LIGHTBLUE -Line $C_BLUEGRAY -Weight 1 -Name 'WorkerPool' | Out-Null
    Add-TextBox -Slide $slide -X 195 -Y 356 -Width 570 -Height 23 -Text 'Worker-Pool · sechs Pipeline-Schritte · Shared Memory · Queues' -FontSize 14 -Color $C_INK -Bold $true -Alignment 2 | Out-Null
    Add-Line -Slide $slide -X1 480 -Y1 391 -X2 480 -Y2 404 -Color $C_NAVY -Weight 1.2 -Arrow $true | Out-Null
    Add-Rect -Slide $slide -X 180 -Y 405 -Width 600 -Height 48 -Fill $C_LIGHTGRAY -Line $C_BLUEGRAY -Weight 1 -Name 'SharedMemory' | Out-Null
    Add-TextBox -Slide $slide -X 195 -Y 418 -Width 570 -Height 23 -Text 'Gemeinsame Datenbasis · Bildblöcke im Shared Memory · Referenzen in Queues' -FontSize 13 -Color $C_INK -Bold $true -Alignment 2 | Out-Null
    Set-Transition $slide
    Set-SpeakerNotes -Slide $slide -Text @'
Sprechzeit: 1:10
Quellenhinweis: Eigene Ausarbeitung, Kapitel 2; Python Software Foundation, multiprocessing.shared_memory-Dokumentation.

Die Prozess-Topologie erklärt die späteren Kaskaden. main.py startet vier langlebige Dienste: InspectionDataHandler, FrameGrabber, PipelineManager und LoggerProcess. Der PipelineManager führt sechs Schritte sequenziell aus und lagert rechenintensive Teilaufgaben in einen Pool mit zwölf Workern aus. Große Bilddaten werden nicht durch die Queues kopiert. Die Queues transportieren kleine Referenzen; die eigentlichen Daten liegen in Shared-Memory-Blöcken. Das ist effizient, erzeugt aber gemeinsame Ressourcen und Abhängigkeiten. Im Referenzbetrieb erreicht ROSI 1,74 Inspektionen pro Sekunde bei durchschnittlich 383 Millisekunden Pipeline-Dauer. Für die Fehlertoleranz entscheidend ist die Supervision. main.py prüft den PipelineManager im Sekundentakt. Die drei übrigen Service-Prozesse besitzen keine vergleichbare Laufzeitreaktion. Die Abbildung zeigt damit zugleich Datenfluss, gemeinsame Log-Queue, Worker-Pool und die unvollständige Supervisionsgrenze.
'@

    # 4 — native fault-injection matrix.
    $slide = $presentation.Slides.AddSlide($presentation.Slides.Count + 1, (Get-Layout $presentation '1Picture_1Text'))
    Set-ContentHeader -Slide $slide -Title 'Untersuchungsdesign: fünf Fault-Injection-Cases' -Source 'Eigene Ausarbeitung, Kap. 4; Hsueh et al. (1997)' -Kicker '02 · METHODIK'
    Remove-VisualPlaceholders -Slide $slide
    Use-BodyPlaceholder -Slide $slide -Text 'Gezielter Fehlerzustand  →  reproduzierbare Beobachtung  →  Vergleich von Erkennung, Folgeverhalten und Degradation' -X 35 -Y 106 -Width 890 -Height 22 -FontSize 13 -Color $C_INK -Bold $true -Alignment 2 | Out-Null
    Add-Line -Slide $slide -X1 35 -Y1 137 -X2 923 -Y2 137 -Color $C_RED -Weight 1.3 | Out-Null
    $methodRows = [string[][]]@(
        @('Case','Eingriff','Untersuchungsziel','Messgrößen'),
        @('C1','SIGKILL','Laufzeit-Supervision','TTD · Shutdown · Dienststatus'),
        @('C2','OSError(28)','Speichergrenze / Fallback','Wachstum · Fehlerzeit · Shutdown'),
        @('C3','SIGSTOP Logger','Queue-Backpressure','qsize · Stillstand · Messlücke'),
        @('C4','DB-Trennung','Persistenzrisiko','OperationalError · Konfiguration'),
        @('C5','Timing-Hypothese','Shared-Memory-Race','Zugriff · Freigabe · Absturz')
    )
    Add-NativeTable -Slide $slide -X 35 -Y 151 -Width 888 -Height 298 -Rows $methodRows -ColumnWidths @(70, 185, 285, 348) -BodyFont 10.5 -Name 'MethodMatrix' | Out-Null
    Add-TextBox -Slide $slide -X 35 -Y 460 -Width 888 -Height 22 -Text 'Direkte Messung und analytische Ableitung werden in den Fällen getrennt ausgewiesen.' -FontSize 11 -Color $C_SLATE -Bold $true -Alignment 2 | Out-Null
    Set-Transition $slide
    Set-SpeakerNotes -Slide $slide -Text @'
Sprechzeit: 0:55
Quellenhinweis: Hsueh, Tsai und Iyer, Fault injection techniques and tools, IEEE Computer 30(4), 1997; eigene Messprotokolle.

Die Methodik folgt dem Fault-Injection-Prinzip: Ein gezielter Fehlerzustand wird in einen laufenden Aufbau eingebracht, anschließend werden Reaktion und Folgeverhalten aufgezeichnet. Die ersten drei Eingriffe sind direkte technische Stellvertreter. SIGKILL beendet einen Prozess hart, OSError(28) repräsentiert einen vollen flüchtigen Speicher, und SIGSTOP friert den Logger ein. In Case 4 werden Datenbankverbindungen serverseitig getrennt. Case 5 verschärft die zeitliche Bedingung einer vermuteten Shared-Memory-Race. Verglichen werden Time-to-Detection, Verhalten der abhängigen Pipeline, Queue- beziehungsweise Speicherzustand und die Frage nach kontrollierter Degradation. Die Tabelle trennt dabei Versuchsreize und Messgrößen. Das ist wichtig für die wissenschaftliche Einordnung: Ein nicht beobachteter Fehlerpfad ist ein Ergebnis, und eine nicht bestätigte Hypothese ebenfalls.
'@

    # 5 — C1 native result table.
    $slide = $presentation.Slides.AddSlide($presentation.Slides.Count + 1, (Get-Layout $presentation '1Picture_1Text'))
    Set-ContentHeader -Slide $slide -Title 'C1 – Prozessausfälle und Laufzeit-Supervision' -Source 'Eigene Messung: C1-Ergebnistabelle; Pont & Ong (2002)' -Kicker '03 · BEFUNDE · C1'
    Remove-VisualPlaceholders -Slide $slide
    Use-BodyPlaceholder -Slide $slide -Text 'SIGKILL auf jeden langlebigen Dienst · Reaktion im Messfenster' -X 35 -Y 106 -Width 610 -Height 20 -FontSize 12.5 -Color $C_INK -Bold $true -Alignment 1 | Out-Null
    $c1Rows = [string[][]]@(
        @('Dienst','Eingriff','Laufzeitreaktion'),
        @('PipelineManager','SIGKILL','0,992 s · geordneter Shutdown'),
        @('FrameGrabber','SIGKILL','keine erkannte Reaktion'),
        @('InspectionDataHandler','SIGKILL','keine erkannte Reaktion'),
        @('Logger','SIGKILL','keine erkannte Reaktion')
    )
    Add-NativeTable -Slide $slide -X 35 -Y 137 -Width 610 -Height 270 -Rows $c1Rows -ColumnWidths @(210, 115, 285) -BodyFont 10.5 -Name 'C1ResultTable' | Out-Null
    # Mark the only fully supervised service without a card or badge.
    $c1Table = $slide.Shapes.Item('C1ResultTable').Table
    for ($col = 1; $col -le 3; $col++) { $c1Table.Cell(2, $col).Shape.Fill.ForeColor.RGB = $C_LIGHTRED; try { $c1Table.Cell(2, $col).Shape.Line.ForeColor.RGB = $C_RED } catch {} }
    Add-Line -Slide $slide -X1 690 -Y1 147 -X2 690 -Y2 400 -Color $C_RED -Weight 2 | Out-Null
    Add-TextBox -Slide $slide -X 720 -Y 159 -Width 180 -Height 65 -Text '1 / 4' -FontSize 40 -Color $C_RED -Bold $true -Alignment 2 | Out-Null
    Add-TextBox -Slide $slide -X 705 -Y 230 -Width 210 -Height 60 -Text "Dienste mit vollständiger`nLaufzeitreaktion" -FontSize 14 -Color $C_INK -Bold $true -Alignment 2 | Out-Null
    Add-TextBox -Slide $slide -X 705 -Y 321 -Width 210 -Height 61 -Text "Befund`nDrei Prozesse zeigen Fail-Silent-Verhalten." -FontSize 13 -Color $C_TEXT -Alignment 2 | Out-Null
    Add-TextBox -Slide $slide -X 35 -Y 431 -Width 880 -Height 25 -Text 'Schutzschicht: Supervisor / systemd für alle vier langlebigen Services.' -FontSize 13 -Color $C_INK -Bold $true -Alignment 2 | Out-Null
    Set-Transition $slide
    Set-SpeakerNotes -Slide $slide -Text @'
Sprechzeit: 1:10
Quellenhinweis: Eigene C1-Messung und Ergebnistabelle; Pont und Ong, watchdog timers, VikingPLoP 2002.

Case 1 prüft die Laufzeit-Supervision direkt. Jeder der vier Service-Prozesse wird einzeln per SIGKILL beendet. Nur beim PipelineManager reagiert main.py innerhalb von 0,992 Sekunden und startet einen geordneten Shutdown. Beim FrameGrabber bleibt der Datenstrom aus und die Pipeline wartet in Schritt 1. Beim InspectionDataHandler endet die Bereitstellung neuer Container; beim Logger fällt die Protokollierung aus. Diese Zustände können zunächst wie ein weiterlaufendes System aussehen, obwohl bereits Daten oder Beobachtbarkeit verloren gehen. Der belastbare Befund lautet deshalb nicht, dass alle Dienste sofort sichtbar abstürzen. Er lautet: Nur einer von vier Prozessausfällen führt im Messfenster zu einer vollständigen technischen Reaktion. Drei Dienste zeigen Fail-Silent-Verhalten. Das begründet eine Supervisor- oder systemd-Überwachung für alle langlebigen Services.
'@

    # 6 — one and only one image asset: original Case 2 figure.
    $slide = $presentation.Slides.AddSlide($presentation.Slides.Count + 1, (Get-Layout $presentation 'Big object + 2 text boxes'))
    Set-ContentHeader -Slide $slide -Title 'C2 – Ressourcenerschöpfung im Bildarchiv' -Source 'Eigene Messdaten: case2_disk_usage_timeseries.csv; Linux Kernel tmpfs-Dokumentation' -Kicker '03 · BEFUNDE · C2'
    Remove-VisualPlaceholders -Slide $slide
    Use-BodyPlaceholder -Slide $slide -Text 'ORIGINALMESSUNG · Images/Out auf der RAM-Disk' -X 35 -Y 105 -Width 520 -Height 20 -FontSize 11 -Color $C_SLATE -Bold $true -Alignment 1 | Out-Null
    Add-Type -AssemblyName System.Drawing
    $image = [System.Drawing.Image]::FromFile((Resolve-Path -LiteralPath $imagePath).Path)
    $imageRatio = [double]$image.Width / [double]$image.Height
    $image.Dispose()
    $imageWidth = 555.0
    $imageHeight = $imageWidth / $imageRatio
    $imageShape = $slide.Shapes.AddPicture((Resolve-Path -LiteralPath $imagePath).Path, $msoFalse, $msoTrue, 35, 137, $imageWidth, $imageHeight)
    $imageShape.Name = 'Case2OriginalMeasurement'
    $imageShape.AlternativeText = 'Original asset: case2_image_out_usage.png; source: case2_image_out_usage.pdf'
    try { $imageShape.Shadow.Visible = $msoFalse } catch {}
    Add-Line -Slide $slide -X1 630 -Y1 143 -X2 630 -Y2 447 -Color $C_RED -Weight 1.8 | Out-Null
    Add-TextBox -Slide $slide -X 665 -Y 151 -Width 245 -Height 45 -Text '+43,6 MB' -FontSize 29 -Color $C_RED -Bold $true -Alignment 2 | Out-Null
    Add-TextBox -Slide $slide -X 665 -Y 198 -Width 245 -Height 25 -Text 'in 46,7 s · direkt gemessen' -FontSize 12 -Color $C_TEXT -Bold $true -Alignment 2 | Out-Null
    Add-TextBox -Slide $slide -X 665 -Y 251 -Width 245 -Height 48 -Text "947 CSV-Zeilen`n≈21,8 MB je Inspektion*" -FontSize 15 -Color $C_INK -Bold $true -Alignment 2 | Out-Null
    Add-Line -Slide $slide -X1 665 -Y1 317 -X2 910 -Y2 317 -Color $C_GRID -Weight 1 | Out-Null
    Add-TextBox -Slide $slide -X 665 -Y 331 -Width 245 -Height 67 -Text "OSError(28) nach 35,2 s`nPipelineManager stürzt ab`nShutdown nach weiteren 2,1 s" -FontSize 13 -Color $C_INK -Alignment 2 | Out-Null
    Add-TextBox -Slide $slide -X 665 -Y 418 -Width 245 -Height 25 -Text '* aus zwei Pipelines abgeleitet' -FontSize 9.5 -Color $C_SLATE -Alignment 2 | Out-Null
    Set-Transition $slide
    Set-SpeakerNotes -Slide $slide -Text @'
Sprechzeit: 1:10
Quellenhinweis: Eigene Messdaten aus case2_disk_usage_timeseries.csv und disk_full.log; Linux Kernel Documentation, tmpfs.

Case 2 untersucht das Bildarchiv auf der RAM-Disk. Die Rohdaten enthalten 947 Zeilen über 46,7 Sekunden. Images/Out wächst in diesem Messlauf um rund 43,6 Megabyte. Am Ende sind zwei Pipelines verzeichnet; daraus ergeben sich rund 21,8 Megabyte je Inspektion. Kombiniert mit dem Referenzdurchsatz von 1,74 Inspektionen pro Sekunde ist das eine Produktionshochrechnung von etwa 38 Megabyte pro Sekunde. Dieser letzte Wert ist ausdrücklich abgeleitet, nicht direkt in der Datei gemessen. Der direkte Mechanismus ist dagegen klar: Der Schreibvorgang löst bei vollem Speicher OSError(28) aus. Die Ausnahme wird nicht lokal abgefangen. Der betroffene Worker stirbt, der PipelineManager wartet rund 35,2 Sekunden und stürzt anschließend ab. Weitere 2,1 Sekunden später ist der Shutdown abgeschlossen. Die Kerninspektion besitzt keinen definierten Fallback für die Archivierung.
'@

    # 7 — C3 native timeline and evidence table, no graph image.
    $slide = $presentation.Slides.AddSlide($presentation.Slides.Count + 1, (Get-Layout $presentation '1Picture_1Text'))
    Set-ContentHeader -Slide $slide -Title 'C3 – Blockierende Log-Queue' -Source 'Eigene Messdaten: queue_depth_timeseries.csv; Python Queue-Dokumentation' -Kicker '03 · BEFUNDE · C3'
    Remove-VisualPlaceholders -Slide $slide
    Use-BodyPlaceholder -Slide $slide -Text 'ZEITLINIE · Logger pausiert, Pipeline folgt' -X 35 -Y 105 -Width 600 -Height 20 -FontSize 11 -Color $C_SLATE -Bold $true -Alignment 1 | Out-Null
    Add-Line -Slide $slide -X1 70 -Y1 185 -X2 885 -Y2 185 -Color $C_NAVY -Weight 1.6 | Out-Null
    $timeline = @(
        @{ X = 120; Label = 't0'; Body = "SIGSTOP`nLogger" ; Color = $C_RED },
        @{ X = 330; Label = 't + 1,3 s'; Body = "letzter`nin-flight Abschluss"; Color = $C_RED },
        @{ X = 580; Label = 't + 30,4 s'; Body = "Messlücke`nMonitor pausiert"; Color = $C_TEXT },
        @{ X = 805; Label = 'SIGCONT'; Body = "Queue leert`nin < 0,3 s"; Color = $C_BLUE }
    )
    foreach ($point in $timeline) {
        Add-Line -Slide $slide -X1 $point.X -Y1 170 -X2 $point.X -Y2 202 -Color $point.Color -Weight 2 | Out-Null
        Add-TextBox -Slide $slide -X ($point.X - 58) -Y 145 -Width 116 -Height 22 -Text $point.Label -FontSize 11 -Color $point.Color -Bold $true -Alignment 2 | Out-Null
        Add-TextBox -Slide $slide -X ($point.X - 73) -Y 209 -Width 146 -Height 43 -Text $point.Body -FontSize 10.5 -Color $C_INK -Bold $true -Alignment 2 | Out-Null
    }
    $c3Rows = [string[][]]@(
        @('Evidenz','Status','Bedeutung'),
        @('17 Pipelines / 5 s','direkt gemessen','vor SIGSTOP'),
        @('qsize max. 6','direkt gemessen','vor Messlücke'),
        @('≈30,4 s ohne Werte','direkt gemessen','Logger und Monitor pausiert'),
        @('Queue-Füllstand 1000','technisch abgeleitet','kein direkter qsize-Nachweis')
    )
    Add-NativeTable -Slide $slide -X 45 -Y 285 -Width 870 -Height 137 -Rows $c3Rows -ColumnWidths @(270, 200, 400) -BodyFont 9.5 -Name 'C3EvidenceTable' | Out-Null
    $c3Table = $slide.Shapes.Item('C3EvidenceTable').Table
    for ($col = 1; $col -le 3; $col++) { $c3Table.Cell(5, $col).Shape.Fill.ForeColor.RGB = $C_LIGHTRED; try { $c3Table.Cell(5, $col).Shape.Line.ForeColor.RGB = $C_RED } catch {} }
    Add-TextBox -Slide $slide -X 45 -Y 439 -Width 870 -Height 24 -Text 'Konsequenz: synchrones put ohne Timeout koppelt Logging an den Inspektionspfad.' -FontSize 12 -Color $C_INK -Bold $true -Alignment 2 | Out-Null
    Set-Transition $slide
    Set-SpeakerNotes -Slide $slide -Text @'
Sprechzeit: 1:10
Quellenhinweis: Eigene Messdaten aus queue_depth_timeseries.csv und cascade.log; Python queue-Dokumentation.

Case 3 zeigt, wie eine Hilfsfunktion Backpressure bis in die Pipeline tragen kann. Der Logger wird per SIGSTOP angehalten. Vor dem Eingriff verarbeitet der Aufbau 17 Pipelines in fünf Sekunden. Danach können noch bereits laufende Pipelines abschließen; nach ungefähr 1,3 Sekunden steht die Verarbeitung. Ursache ist das synchrone Schreiben in eine zentrale Log-Queue. Der put-Aufruf wartet ohne Timeout. Sobald der Logger nicht mehr liest, blockieren weitere Prozesse beim nächsten Log-Eintrag und damit im normalen Ablauf. Die CSV zeichnet vor der Pause qsize-Werte bis maximal sechs auf. Danach folgt eine Messlücke von rund 30,4 Sekunden, weil Logger und Monitor gemeinsam pausiert waren. Nach SIGCONT leert sich die Queue in weniger als 0,3 Sekunden. Die Folie markiert die vermutete volle Queue als Ableitung, nicht als direkt gemessenen qsize-1000-Wert. Ein Timeout mit Drop-on-Full würde Log-Einträge opfern, aber den Inspektionspfad entkoppeln.
'@

    # 8 — C4 native comparison table.
    $slide = $presentation.Slides.AddSlide($presentation.Slides.Count + 1, (Get-Layout $presentation '1Picture_1Text'))
    Set-ContentHeader -Slide $slide -Title 'C4 – Veraltete Datenbankverbindungen' -Source 'Eigene Ausarbeitung, Kap. 5.4; Django Documentation' -Kicker '03 · BEFUNDE · C4'
    Remove-VisualPlaceholders -Slide $slide
    Use-BodyPlaceholder -Slide $slide -Text 'NEGATIVKONTROLLE VS. PRODUKTIONSRISIKO' -X 35 -Y 105 -Width 870 -Height 20 -FontSize 11 -Color $C_SLATE -Bold $true -Alignment 2 | Out-Null
    $c4Rows = [string[][]]@(
        @('Entwicklung (direkt getestet)','Produktion (analytisch abgeleitet)'),
        @('27 Verbindungen terminiert','Persistente Verbindung nach Pause'),
        @('kein OperationalError','veraltete TCP-Verbindung möglich'),
        @('frische Verbindung je Zugriff','Produktionskonfiguration zu bestätigen'),
        @('Negativkontrolle: Pfad maskiert','Nächster Test: Pause + kontrollierter Reopen')
    )
    Add-NativeTable -Slide $slide -X 55 -Y 150 -Width 850 -Height 245 -Rows $c4Rows -ColumnWidths @(425, 425) -BodyFont 13 -Name 'C4Comparison' | Out-Null
    Add-Line -Slide $slide -X1 55 -Y1 418 -X2 905 -Y2 418 -Color $C_RED -Weight 1.4 | Out-Null
    Add-TextBox -Slide $slide -X 55 -Y 431 -Width 850 -Height 26 -Text 'Aussagegrenze: Der konkrete Produktionswert von CONN_MAX_AGE ist vor der Bewertung zu bestätigen.' -FontSize 11.5 -Color $C_INK -Bold $true -Alignment 2 | Out-Null
    Set-Transition $slide
    Set-SpeakerNotes -Slide $slide -Text @'
Sprechzeit: 1:10
Quellenhinweis: Eigene Ausarbeitung, Kapitel 5.4, und dem Messprotokoll zu Fall 4; Django Software Foundation, Databases – Persistent connections.

Case 4 muss anders gelesen werden als C1 bis C3. Der vorhandene Test läuft in der Entwicklungskonfiguration. Dort öffnet Django pro Zugriff eine frische Verbindung. Während des Betriebs werden 27 Datenbankverbindungen terminiert; trotzdem tritt kein OperationalError auf und der Aufbau arbeitet weiter. Das ist eine Negativkontrolle: Sie zeigt, dass die Entwicklungsumgebung den vermuteten Produktionspfad maskiert. Die Ableitung betrifft eine persistente Produktionsverbindung nach einer Anlagenpause. PostgreSQL oder eine vorgelagerte Firewall kann die inaktive TCP-Verbindung trennen, während der Client sie noch als gültig betrachtet. Der erste Schreibzugriff danach kann einen ungefangenen OperationalError auslösen. Die konkrete Produktionskonfiguration muss vor einer abschließenden Bewertung bestätigt werden. Deshalb nennt die Folie keinen festen CONN_MAX_AGE-Wert. Der sinnvolle nächste Test ist eine realistische Pause mit Produktionskonfiguration sowie ein kontrollierter Verbindungs-Reopen oder einzelner Retry.
'@

    # 9 — C5 native timing comparison.
    $slide = $presentation.Slides.AddSlide($presentation.Slides.Count + 1, (Get-Layout $presentation '1Picture_1Text'))
    Set-ContentHeader -Slide $slide -Title 'C5 – Prüfung einer Shared-Memory-Race-Hypothese' -Source 'Eigene Messung: case5_gc_race.log; Python shared_memory-Dokumentation' -Kicker '03 · BEFUNDE · C5'
    Remove-VisualPlaceholders -Slide $slide
    Use-BodyPlaceholder -Slide $slide -Text 'TIMING-VERGLEICH · gemessener Zugriff gegenüber regulärer Freigabe' -X 35 -Y 105 -Width 870 -Height 20 -FontSize 11 -Color $C_SLATE -Bold $true -Alignment 2 | Out-Null
    Add-TextBox -Slide $slide -X 50 -Y 155 -Width 250 -Height 20 -Text 'Letzter Zugriff · Schritt 5' -FontSize 12 -Color $C_INK -Bold $true | Out-Null
    Add-Rect -Slide $slide -X 315 -Y 154 -Width 115 -Height 23 -Fill $C_LIGHTBLUE -Line $C_BLUEGRAY -Weight 1 -Name 'C5AccessBar' | Out-Null
    Add-TextBox -Slide $slide -X 322 -Y 157 -Width 101 -Height 17 -Text '45–107 ms' -FontSize 10.5 -Color $C_NAVY -Bold $true -Alignment 2 | Out-Null
    Add-TextBox -Slide $slide -X 465 -Y 155 -Width 400 -Height 20 -Text 'direkt gemessen · letzter relevanter Zugriff' -FontSize 11 -Color $C_TEXT | Out-Null
    Add-TextBox -Slide $slide -X 50 -Y 214 -Width 250 -Height 20 -Text 'Reguläre GC-Freigabe' -FontSize 12 -Color $C_INK -Bold $true | Out-Null
    Add-Rect -Slide $slide -X 315 -Y 213 -Width 500 -Height 23 -Fill $C_LIGHTGRAY -Line $C_BLUEGRAY -Weight 1 -Name 'C5GcBar' | Out-Null
    Add-TextBox -Slide $slide -X 322 -Y 216 -Width 486 -Height 17 -Text '≈10 s · reguläre Schwelle' -FontSize 10.5 -Color $C_INK -Bold $true -Alignment 2 | Out-Null
    Add-TextBox -Slide $slide -X 465 -Y 247 -Width 400 -Height 19 -Text 'technischer Referenzwert · kein Fehlerereignis' -FontSize 11 -Color $C_TEXT | Out-Null
    Add-Line -Slide $slide -X1 50 -Y1 290 -X2 905 -Y2 290 -Color $C_GRID -Weight 1 | Out-Null
    $c5Rows = [string[][]]@(
        @('Beobachtung','Wert','Einordnung'),
        @('Zugriff in Schritt 5','45–107 ms','direkt gemessen'),
        @('GC-Freigabe','≈10 s','reguläre Schwelle'),
        @('Zeitlicher Puffer','≈100×','aus den Werten abgeleitet')
    )
    Add-NativeTable -Slide $slide -X 50 -Y 307 -Width 855 -Height 116 -Rows $c5Rows -ColumnWidths @(290, 180, 385) -BodyFont 10 -Name 'C5TimingTable' | Out-Null
    Add-Line -Slide $slide -X1 50 -Y1 442 -X2 50 -Y2 470 -Color $C_RED -Weight 2 | Out-Null
    Add-TextBox -Slide $slide -X 65 -Y 441 -Width 840 -Height 30 -Text 'Kein FileNotFoundError, BrokenPipeError oder Absturz in 120 s · Hypothese im getesteten Aufbau nicht bestätigt.' -FontSize 11.5 -Color $C_INK -Bold $true | Out-Null
    Set-Transition $slide
    Set-SpeakerNotes -Slide $slide -Text @'
Sprechzeit: 0:55
Quellenhinweis: Eigene Messung aus case5_gc_race.log; Python Software Foundation, multiprocessing.shared_memory-Dokumentation.

Case 5 prüft eine plausible Race-Condition im Shared-Memory-Garbage-Collector. Die Hypothese lautet, dass ein Block freigegeben wird, während die Pipeline ihn noch benötigt. Dazu werden die reguläre Freigabeschwelle verschärft und ein nachgelagerter Verarbeitungsschritt verzögert. Über 120 Sekunden tritt weder ein FileNotFoundError noch ein BrokenPipeError oder ein Prozessabsturz auf. Die Timing-Daten erklären den negativen Befund: Der letzte relevante Zugriff in Schritt 5 liegt typischerweise bei 45 bis 107 Millisekunden, während die reguläre Freigabe erst nach zehn Sekunden einsetzt. Das entspricht ungefähr einem hundertfachen zeitlichen Puffer. Das Ergebnis ist eine Eingrenzung, kein Beweis für jede denkbare Race-Condition: Die konkrete Hypothese wurde im getesteten Aufbau nicht bestätigt. Deshalb wird hier kein Sofortfix empfohlen.
'@

    # 10 — native causal synthesis.
    $slide = $presentation.Slides.AddSlide($presentation.Slides.Count + 1, (Get-Layout $presentation '1Picture_1Text'))
    Set-ContentHeader -Slide $slide -Title 'Synthetisierte Ursache-Wirkungs-Kette' -Source 'Eigene Synthese, Kap. 6; Avizienis et al. (2004)' -Kicker '04 · SYNTHESE'
    Remove-VisualPlaceholders -Slide $slide
    Use-BodyPlaceholder -Slide $slide -Text 'C1–C4 zeigen dasselbe Muster an unterschiedlichen technischen Grenzen' -X 35 -Y 105 -Width 870 -Height 20 -FontSize 13 -Color $C_INK -Bold $true -Alignment 2 | Out-Null
    $chain = @(
        @{ X = 35; Head = 'LOKALER FEHLER'; Body = "Prozess`nSpeicher`nQueue`nVerbindung"; Fill = $C_LIGHTGRAY; Line = $C_BLUEGRAY },
        @{ X = 215; Head = 'SCHUTZLÜCKE'; Body = "keine`nSupervision`nkein Timeout"; Fill = $C_LIGHTGRAY; Line = $C_BLUEGRAY },
        @{ X = 395; Head = 'WEITERGABE'; Body = "Warten`nveralteter Zustand`nAusnahme"; Fill = $C_LIGHTRED; Line = $C_RED },
        @{ X = 575; Head = 'SYSTEMFOLGE'; Body = "Pipeline`nsteht"; Fill = $C_LIGHTRED; Line = $C_RED },
        @{ X = 755; Head = 'SCHUTZSCHICHT'; Body = "erkennen`nentkoppeln`nweiterarbeiten"; Fill = $C_LIGHTBLUE; Line = $C_NAVY }
    )
    foreach ($item in $chain) {
        Add-Rect -Slide $slide -X $item.X -Y 177 -Width 160 -Height 125 -Fill $item.Fill -Line $item.Line -Weight 1.2 -Name "Chain_$($item.Head)" | Out-Null
        Add-TextBox -Slide $slide -X ($item.X + 8) -Y 190 -Width 144 -Height 20 -Text $item.Head -FontSize 9 -Color $C_SLATE -Bold $true -Alignment 2 | Out-Null
        Add-TextBox -Slide $slide -X ($item.X + 12) -Y 224 -Width 136 -Height 76 -Text $item.Body -FontSize 15 -Color $C_INK -Bold $true -Alignment 2 | Out-Null
    }
    for ($i = 0; $i -lt 4; $i++) { Add-Line -Slide $slide -X1 ($chain[$i].X + 160) -Y1 240 -X2 ($chain[$i + 1].X - 8) -Y2 240 -Color $C_NAVY -Weight 1.2 -Arrow $true | Out-Null }
    Add-Line -Slide $slide -X1 35 -Y1 353 -X2 923 -Y2 353 -Color $C_RED -Weight 1.5 | Out-Null
    Add-TextBox -Slide $slide -X 35 -Y 370 -Width 125 -Height 20 -Text 'ANTWORT' -FontSize 9.5 -Color $C_RED -Bold $true | Out-Null
    Add-TextBox -Slide $slide -X 170 -Y 365 -Width 740 -Height 48 -Text 'Normalbetrieb stabil; Fehlerfall braucht Schutzschichten aus Sichtbarkeit, Timeout, Retry und kontrollierter Degradation.' -FontSize 17 -Color $C_INK -Bold $true -Alignment 2 | Out-Null
    Add-TextBox -Slide $slide -X 35 -Y 435 -Width 888 -Height 22 -Text 'C5 grenzt die Synthese ein: Die konkrete Race-Hypothese wurde im Test nicht bestätigt.' -FontSize 11 -Color $C_SLATE -Alignment 2 | Out-Null
    Set-Transition $slide
    Set-SpeakerNotes -Slide $slide -Text @'
Sprechzeit: 1:05
Quellenhinweis: Eigene Synthese aus den Cases; Avizienis et al., Dependability-Taxonomie, 2004.

Die fünf Cases ergeben ein konsistentes, aber differenziertes Bild. C1 zeigt fehlende Prozesssupervision. C2 zeigt, dass ein lokaler Ressourcenfehler die Verarbeitung beendet. C3 zeigt, wie eine blockierte Log-Queue Backpressure bis in den Inspektionspfad trägt. C4 beschreibt ein Produktionsrisiko, das durch die Entwicklungskonfiguration verdeckt wird. In diesen vier Fällen fehlt zwischen lokalem Auslöser und globaler Wirkung eine Schutzschicht aus Sichtbarkeit, Timeout, Retry oder kontrollierter Degradation. C5 ist die notwendige Einschränkung: Nicht jede plausible Hypothese bestätigt sich, weil der zeitliche Puffer im getesteten Aufbau groß ist. Die Antwort auf die Forschungsfrage lautet daher nicht, ROSI sei im Normalbetrieb unzuverlässig. Die Baseline läuft. Die Verfügbarkeit im Fehlerfall hängt vielmehr davon ab, ob lokale Störungen erkannt und isoliert werden. Genau an diesen Schutzgrenzen setzen die Empfehlungen an.
'@

    # 11 — recommendations as native columns.
    $slide = $presentation.Slides.AddSlide($presentation.Slides.Count + 1, (Get-Layout $presentation 'Content | 4 text boxes'))
    Set-ContentHeader -Slide $slide -Title 'Handlungsempfehlungen für den Dauerbetrieb' -Source 'Eigene Handlungsempfehlungen, Kap. 6; Pont & Ong (2002)' -Kicker '05 · ENTSCHEIDUNG'
    Clear-ContentPlaceholders -Slide $slide
    $recommendations = @(
        @{ X = 35; Head = 'ERKENNEN'; Body = "Alle vier Services überwachen.`n`nSupervisor / systemd"; Color = $C_RED },
        @{ X = 255; Head = 'BEGRENZEN'; Body = "RAM-Disk-Füllstand alarmieren.`n`nArchivierung kontrolliert degradieren"; Color = $C_NAVY },
        @{ X = 475; Head = 'ENTKOPPELN'; Body = "Logging mit Timeout + Drop-on-Full.`n`nInspektion weiterführen"; Color = $C_NAVY },
        @{ X = 695; Head = 'ERNEUERN'; Body = "close_old_connections().`n`nSchreibzugriff kontrolliert wiederholen"; Color = $C_NAVY }
    )
    for ($i = 0; $i -lt $recommendations.Count; $i++) {
        $item = $recommendations[$i]
        Add-Line -Slide $slide -X1 $item.X -Y1 112 -X2 ($item.X + 175) -Y2 112 -Color $item.Color -Weight 2 | Out-Null
        Add-TextBox -Slide $slide -X $item.X -Y 125 -Width 175 -Height 22 -Text $item.Head -FontSize 12 -Color $item.Color -Bold $true -Alignment 2 | Out-Null
        Add-TextBox -Slide $slide -X ($item.X + 5) -Y 170 -Width 165 -Height 110 -Text $item.Body -FontSize 13 -Color $C_INK -Bold $true -Alignment 2 | Out-Null
        if ($i -lt 3) { Add-Line -Slide $slide -X1 ($item.X + 200) -Y1 115 -X2 ($item.X + 200) -Y2 330 -Color $C_GRID -Weight 1 | Out-Null }
    }
    Add-Line -Slide $slide -X1 35 -Y1 338 -X2 923 -Y2 338 -Color $C_GRID -Weight 1 | Out-Null
    Add-TextBox -Slide $slide -X 35 -Y 358 -Width 888 -Height 50 -Text 'C5 erhält bewusst keinen Sofortfix: Die konkrete Race-Hypothese wurde im getesteten Aufbau nicht bestätigt.' -FontSize 15 -Color $C_INK -Bold $true -Alignment 2 | Out-Null
    Set-Transition $slide
    Set-SpeakerNotes -Slide $slide -Text @'
Sprechzeit: 1:20
Quellenhinweis: Eigene Handlungsempfehlungen, Kapitel 6; Pont und Ong, watchdog timers, VikingPLoP 2002.

Aus den Befunden folgen vier Maßnahmen. Erstens sollten alle vier langlebigen Dienste überwacht werden. Das kann als zentrale Supervisor-Logik oder über systemd erfolgen; wichtig ist eine definierte Reaktion aus Neustart, kontrolliertem Shutdown oder sichtbarem Alarm. Zweitens muss ein voller Bildspeicher lokal behandelt werden. Der Füllstand sollte frühzeitig alarmiert werden. Wenn die Archivierung nicht mehr möglich ist, braucht die Kerninspektion einen definierten Degradationspfad. Drittens darf Logging die Bildverarbeitung nicht blockieren. Ein Timeout und Drop-on-Full entkoppeln die Hilfsfunktion; verlorene Log-Einträge sind operativ besser als ein stillstehender Prüfprozess. Viertens sollten persistente Datenbankverbindungen vor dem Schreiben erneuert werden. Ein einzelner kontrollierter Retry begrenzt den Fehlerpfad. Diese Vorschläge verlangen keine neue KI-Funktion. Sie adressieren genau die Prozess-, Speicher-, Queue- und Persistenzgrenzen, an denen C1 bis C4 lokale Fehler global werden lassen. C5 erhält bewusst keinen Sofortfix, weil der Test die konkrete Hypothese nicht bestätigt hat.
'@

    # 12 — limitations as native columns.
    $slide = $presentation.Slides.AddSlide($presentation.Slides.Count + 1, (Get-Layout $presentation 'Content | 4 text boxes'))
    Set-ContentHeader -Slide $slide -Title 'Evidenzgrenzen und Produktionstransfer' -Source 'Eigene Ausarbeitung, Kap. 4.5; Methodenkritik' -Kicker '06 · GRENZEN'
    Clear-ContentPlaceholders -Slide $slide
    $limits = @(
        @{ X = 35; Head = 'LABOR'; Body = "Referenzsystem + Simulator`n`nMechanismen wahrscheinlich übertragbar"; Color = $C_NAVY },
        @{ X = 255; Head = 'ZEIT'; Body = "20–120 s je Test`n`nLangzeiteffekte hochgerechnet"; Color = $C_NAVY },
        @{ X = 475; Head = 'STICHPROBE'; Body = "Einzelmessungen`n`nkeine Statistik"; Color = $C_NAVY },
        @{ X = 695; Head = 'TRANSFER'; Body = "C4 analytisch`n`nProduktionskonfiguration offen"; Color = $C_RED }
    )
    for ($i = 0; $i -lt $limits.Count; $i++) {
        $item = $limits[$i]
        Add-Line -Slide $slide -X1 $item.X -Y1 112 -X2 ($item.X + 175) -Y2 112 -Color $item.Color -Weight 2 | Out-Null
        Add-TextBox -Slide $slide -X $item.X -Y 125 -Width 175 -Height 22 -Text $item.Head -FontSize 12 -Color $item.Color -Bold $true -Alignment 2 | Out-Null
        Add-TextBox -Slide $slide -X ($item.X + 5) -Y 170 -Width 165 -Height 110 -Text $item.Body -FontSize 13 -Color $C_INK -Bold $true -Alignment 2 | Out-Null
        if ($i -lt 3) { Add-Line -Slide $slide -X1 ($item.X + 200) -Y1 115 -X2 ($item.X + 200) -Y2 330 -Color $C_GRID -Weight 1 | Out-Null }
    }
    Add-Line -Slide $slide -X1 35 -Y1 338 -X2 923 -Y2 338 -Color $C_RED -Weight 1.3 | Out-Null
    Set-Transition $slide
    Set-SpeakerNotes -Slide $slide -Text @'
Sprechzeit: 0:55
Quellenhinweis: Eigene Ausarbeitung, Kapitel 4.5; Fallstudienprotokolle und Sperrvermerk.

Die Ergebnisse sind innerhalb ihres Gültigkeitsbereichs belastbar. Die Versuche liefen auf dem Referenzsystem im Labor mit simulierten Bilddaten, nicht auf der späteren Kundenhardware. Die beobachteten Mechanismen sind wahrscheinlich übertragbar, absolute Zeiten aber nicht garantiert. Die Testfenster lagen zwischen 20 und 120 Sekunden; Langzeiteffekte wurden teilweise aus den gemessenen Raten hochgerechnet. Jeder Case basiert auf einer Einzelmessung. Die Arbeit bewertet daher Mechanismen und Größenordnungen, keine statistischen Verteilungen. C4 ist analytisch, weil die Entwicklungskonfiguration den vermuteten Produktionspfad gerade maskiert. Vor einer technischen Entscheidung müssen Produktionskonfiguration und realistische Anlagenpause nachgestellt werden. Der Sperrvermerk bleibt bestehen: Interne Hostnamen, Zugangsdaten, PIDs und nicht freigegebene Kundendetails gehören nicht in die Präsentation.
'@

    # 13 — native Thank-you layout.
    $slide = $presentation.Slides.AddSlide($presentation.Slides.Count + 1, (Get-Layout $presentation 'Thank you'))
    Set-TitleSlide -Slide $slide -Title 'Fazit und Diskussion' -Subtitle 'Vielen Dank · Fragen?'
    Set-Transition $slide
    Set-SpeakerNotes -Slide $slide -Text @'
Sprechzeit: 0:25
Quellenhinweis: Zusammenfassung der eigenen Fallstudie.

Die Fallstudie lässt sich in drei Verben zusammenfassen: erkennen, entkoppeln, weiterarbeiten. Kritische Dienste, Queues und Speicherzustände müssen sichtbar sein. Lokale Fehler brauchen Timeout, Retry und kontrollierte Degradation, damit sie nicht die gesamte Pipeline mitreißen. Die Produktionskonfiguration sollte gezielt unter realistischen Pausen getestet werden. Die Untersuchung zeigt damit keinen Bedarf für eine neue KI-Funktion als ersten Schritt, sondern für klarere Schutzschichten an den Prozess-, Speicher- und Persistenzgrenzen. Vielen Dank für Ihre Aufmerksamkeit. Ich freue mich auf Fragen zu den Messungen, den Evidenzgrenzen oder den vorgeschlagenen Maßnahmen.
'@

    # Kurze Moderationsstützen statt ausformuliertem Vortragsmanuskript.
    $shortNotes = @(
        "Sprechzeit: 0:50`nQuellenhinweis: Avizienis et al. (2004); eigene Fallstudie.`n`n- ROSI: optische Inline-Inspektion im industriellen Dauerbetrieb.`n- Fokus: Verfügbarkeit, Ausfalltoleranz und Konsistenz.`n- Fünf Fault-Injection-Cases mit unterschiedlichen Evidenzstufen.",
        "Sprechzeit: 0:55`nQuellenhinweis: Eigene Ausarbeitung, Kapitel 1; Avizienis et al. (2004).`n`n- Materialfluss und Inspektion laufen kontinuierlich.`n- Lokale Softwarefehler können betriebliche Folgen auslösen.`n- Leitfrage: Erkennt und begrenzt ROSI diese Fehler rechtzeitig?",
        "Sprechzeit: 1:10`nQuellenhinweis: Eigene Ausarbeitung, Kapitel 2; Python shared_memory-Dokumentation.`n`n- Vier langlebige Dienste und zwölf Worker.`n- Bilddaten im Shared Memory, Referenzen in Queues.`n- Baseline: 1,74 Inspektionen pro Sekunde bei 383 Millisekunden.`n- Nur der PipelineManager wird laufend überwacht.",
        "Sprechzeit: 0:55`nQuellenhinweis: Hsueh, Tsai und Iyer (1997); eigene Messprotokolle.`n`n- Definierter Fehlerzustand, reproduzierbarer Eingriff, beobachtete Reaktion.`n- C1 bis C5 verwenden unterschiedliche Injektionsmechanismen.`n- Messung und analytische Ableitung bleiben getrennt.",
        "Sprechzeit: 1:10`nQuellenhinweis: Eigene C1-Messung; Pont und Ong (2002).`n`n- Jeder langlebige Dienst wurde einzeln per SIGKILL beendet.`n- Nur PipelineManager erkannt: TTD 0,992 Sekunden.`n- Drei Dienste zeigen keine vollständige Top-Level-Reaktion.`n- Konsequenz: Supervision für alle langlebigen Services.",
        "Sprechzeit: 1:10`nQuellenhinweis: case2_disk_usage_timeseries.csv; disk_full.log; Linux tmpfs-Dokumentation.`n`n- Images/Out wächst im Messfenster um 43,6 Megabyte.`n- Etwa 21,8 Megabyte je Inspektion; Produktionsrate nur hochgerechnet.`n- OSError(28) wird nicht lokal abgefangen.`n- PipelineManager-Absturz nach 35,2 Sekunden, danach Shutdown.",
        "Sprechzeit: 1:10`nQuellenhinweis: queue_depth_timeseries.csv; cascade.log; Python queue-Dokumentation.`n`n- SIGSTOP hält Logger und Queue-Monitor an.`n- Nach etwa 1,3 Sekunden steht die Verarbeitung.`n- Messlücke: 30,4 Sekunden; qsize außerhalb maximal sechs.`n- Queue-Sättigung ist technisch abgeleitet, nicht direkt gemessen.`n- Timeout und Drop-on-Full würden Logging entkoppeln.",
        "Sprechzeit: 1:10`nQuellenhinweis: Eigene Ausarbeitung, Kapitel 5.4; Django-Dokumentation.`n`n- Entwicklungstest: 27 Verbindungen terminiert, kein OperationalError.`n- Negativkontrolle maskiert das Produktionsrisiko.`n- Persistente Verbindung kann nach Anlagenpause veraltet sein.`n- Produktionskonfiguration und Pausenszenario direkt validieren.",
        "Sprechzeit: 0:55`nQuellenhinweis: case5_gc_race.log; Python shared_memory-Dokumentation.`n`n- Hypothese: vorzeitige Freigabe eines benötigten Shared-Memory-Blocks.`n- Letzter Zugriff: 45 bis 107 Millisekunden.`n- Reguläre Freigabeschwelle: ungefähr zehn Sekunden.`n- Kein Fehler in 120 Sekunden; Hypothese nicht bestätigt.",
        "Sprechzeit: 1:05`nQuellenhinweis: Eigene Synthese, Kapitel 6; Avizienis et al. (2004).`n`n- C1 bis C4 zeigen wiederkehrende Schutzlücken.`n- Lokale Fehler propagieren über fehlende Supervision, Timeouts oder Retries.`n- Baseline stabil; Fehlerisolation bleibt unvollständig.`n- C5 begrenzt die Verallgemeinerung.",
        "Sprechzeit: 1:20`nQuellenhinweis: Eigene Handlungsempfehlungen, Kapitel 6; Pont und Ong (2002).`n`n- Alle langlebigen Dienste überwachen.`n- Speichergrenzen alarmieren und kontrolliert degradieren.`n- Logging durch Timeout und Drop-on-Full entkoppeln.`n- Datenbankverbindungen erneuern und gezielt wiederholen.",
        "Sprechzeit: 0:55`nQuellenhinweis: Eigene Ausarbeitung, Kapitel 4.5; Fallstudienprotokolle und Sperrvermerk.`n`n- Laboraufbau mit Simulator statt Kundenhardware.`n- Testfenster zwischen 20 und 120 Sekunden.`n- Einzelmessungen ohne statistische Absicherung.`n- C4 bleibt analytisch; Produktionskonfiguration ist offen.`n- Sperrvermerk: keine internen Zugangsdaten oder Kundendetails zeigen.",
        "Sprechzeit: 0:25`nQuellenhinweis: Zusammenfassung der eigenen Fallstudie.`n`n- Dienste und Ressourcen sichtbar machen.`n- Lokale Fehler entkoppeln und kontrolliert degradieren.`n- Nächster Schritt: produktionsnahe Validierung.`n- Vielen Dank – Fragen?"
    )
    for ($i = 0; $i -lt $shortNotes.Count; $i++) {
        Set-SpeakerNotes -Slide $presentation.Slides.Item($i + 1) -Text $shortNotes[$i]
    }

    foreach ($item in @($presentation.Slides)) { Enable-NativeFooter -Slide $item }

    $presentation.SaveAs($OutputPath, $ppSaveAsOpenXMLPresentation)
    [pscustomobject]@{
        Output = $OutputPath
        Slides = $presentation.Slides.Count
        Template = $TemplatePath
        EmbeddedImageAsset = $imagePath
        NativeVisuals = $true
        FadeEffect = $fadeEffect
        NativeFooter = $footerText
    } | ConvertTo-Json
} finally {
    if ($templateReference) { $templateReference.Close() }
    if ($presentation) { $presentation.Close() }
    if ($powerPoint) { $powerPoint.Quit() }
    if ($presentation) { [void][Runtime.InteropServices.Marshal]::ReleaseComObject($presentation) }
    if ($templateReference) { [void][Runtime.InteropServices.Marshal]::ReleaseComObject($templateReference) }
    if ($powerPoint) { [void][Runtime.InteropServices.Marshal]::ReleaseComObject($powerPoint) }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}
