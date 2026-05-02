---
document type: cmdlet
external help file: DisplayConfig.dll-Help.xml
HelpUri: ''
Locale: da-DK
Module Name: DisplayConfig
ms.date: 05-02-2026
PlatyPS schema version: 2024-05-01
title: Disable-DisplayWCG
---

# Disable-DisplayWCG

## SYNOPSIS

Disables Wide Color Gamut for the display. This is the same as toggling the "Automatically manage color for apps" switch in the display color profile settings.

## SYNTAX

### __AllParameterSets

```
Disable-DisplayWCG [-DisplayId] <uint[]> [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases,
  None

## DESCRIPTION

Disables Wide Color Gamut for the display. This is the same as toggling the "Automatically manage color for apps" switch in the display color profile settings.

## EXAMPLES

### Example 1

PS C:\> Disable-DisplayWCG -DisplayId 3

Disables Wide Color Gamut on the display AKA "Automatically manage color for apps".

## PARAMETERS

### -DisplayId

The display where WCG should be disabled.
DisplayIds in this module use a similar logic as the Windows Settings app to number the displays, but there's no guarantee that it will match on every system.
Displays are sorted by the output port on the adapter with the following priority: Internal displays (laptops), PC connectors (DVI, Displayport), HDMI and others.
When multiple displays use the same connector (eg. 2 DisplayPort monitors) Windows will assign an incrementing number for each instance, and this number is combined with the priority to determine the exact display order.
The only way to change the displayId of a display is to move it to a different port on the graphics adapter.

```yaml
Type: System.UInt32[]
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES


## RELATED LINKS

