'  Date & Time related functions for PB/DLL and PB/CC
'  Copyright (c) 2000 by PowerBASIC, Inc.
'
'  Notes:
'
'  A VB time variable is stored as an 8-byte real value (double), representing
'  a date between January 1, 1753 and December 31, 2078, inclusive. The value
'  2.0 represents January 1, 1900; 3.0 represents January 2, 1900, and so on.
'  Adding 1 to the value increments the date by a day. The fractional part of
'  the value represents the time of day. Therefore, 2.5 represents noon on
'  Janurary 1, 1900; 3.25 represents 6:00 A.M. on January 2, 1900, and so on.
'  Negative numbers represent the dates prior to December 30, 1899. '
'
'==============================================================================
 
' #INCLUDE "WIN32API.INC"
 
'=============================[ Global Variables ]=============================
 
GLOBAL z AS ASCIIZ * 64
 
'==============================[ Date Functions ]==============================
 
'------------------------------------------------------------------------------
' Callback function for EnumCalender calls
'
FUNCTION EnumCalendarProc(c AS ASCIIZ) AS LONG
 
  z = c  'assign result to global variable
 
END FUNCTION
 
'------------------------------------------------------------------------------
' Return the name of a month using the current language settings
'
' m = value between 1 and 12 where 1 is "January"
'
FUNCTION MonthName(BYVAL m AS LONG) AS STRING
 
  EnumCalendarInfo CODEPTR(EnumCalendarProc), %LOCALE_SYSTEM_DEFAULT, 1, %CAL_SMONTHNAME1 + m - 1
 
  FUNCTION = z
 
END FUNCTION
 
'------------------------------------------------------------------------------
' Return the name of a day using the current language settings
'
' d = value between 0 and 6 where 0 is "Sunday"
'
FUNCTION DayName(BYVAL d AS LONG) AS STRING
 
  EnumCalendarInfo CODEPTR(EnumCalendarProc), %LOCALE_SYSTEM_DEFAULT, 1, %CAL_SDAYNAME1 + d
 
  FUNCTION = z
 
END FUNCTION
 
'------------------------------------------------------------------------------
' Return the current date and time as a DOUBLE (compatible with VB)
'
FUNCTION Now() AS DOUBLE
 
  LOCAL st     AS SYSTEMTIME
  LOCAL vbDate AS DOUBLE
 
  GetLocalTime st
  SystemTimeToVariantTime st, vbDate
 
  FUNCTION = vbDate
 
END FUNCTION
 
'------------------------------------------------------------------------------
' Return a SYSTEMTIME structure from a VB date
'
SUB DateToSystemDate(BYVAL d AS DOUBLE, st AS SYSTEMTIME)
 
  VariantTimeToSystemTime d, st
 
END SUB
 
'------------------------------------------------------------------------------
' Return the month from a VB date
'
FUNCTION Month(BYVAL d AS DOUBLE) AS LONG
 
  LOCAL st AS SYSTEMTIME
 
  DateToSystemDate d, st
 
  FUNCTION = st.wMonth
 
END FUNCTION
 
'------------------------------------------------------------------------------
' Return the day from a VB date
'
FUNCTION Day(BYVAL d AS DOUBLE) AS LONG
 
  LOCAL st AS SYSTEMTIME
 
  DateToSystemDate d, st
 
  FUNCTION = st.wDay
 
END FUNCTION
 
FUNCTION DayOfWeek(BYVAL d AS DOUBLE) AS LONG
 
  LOCAL iDay As Long
  LOCAL st AS SYSTEMTIME
 
  DateToSystemDate d, st
 
  ' FUNCTION = st.wDayOfWeek
  iDay = st.wDayOfWeek
  iDay -= 1
  If iDay < 0 Then iDay = 6
  Function = iDay
 
END FUNCTION
 
 

'------------------------------------------------------------------------------
' Return the year from a VB date
'
FUNCTION Year(BYVAL d AS DOUBLE) AS LONG
 
  LOCAL st AS SYSTEMTIME
 
  DateToSystemDate d, st
 
  FUNCTION = st.wYear
 
END FUNCTION
 
'------------------------------------------------------------------------------
' Return the hour from a VB date
'
FUNCTION Hour(BYVAL d AS DOUBLE) AS LONG
 
  LOCAL st AS SYSTEMTIME
 
  DateToSystemDate d, st
 
  FUNCTION = st.wHour
 
END FUNCTION
 
'------------------------------------------------------------------------------
' Return the minute from a VB date
'
FUNCTION Minute(BYVAL d AS DOUBLE) AS LONG
 
  LOCAL st AS SYSTEMTIME
 
  DateToSystemDate d, st
 
  FUNCTION = st.wMinute
 
END FUNCTION
 
'------------------------------------------------------------------------------
' Return the second from a VB date
'
FUNCTION Second(BYVAL d AS DOUBLE) AS LONG
 
  LOCAL st AS SYSTEMTIME
 
  DateToSystemDate d, st
 
  FUNCTION = st.wSecond
 
END FUNCTION
 
'------------------------------------------------------------------------------
' Convert a string into a VB date
'
FUNCTION StrToDate(BYVAL d AS STRING) AS DOUBLE
 
  LOCAL vbdate AS DOUBLE
  LOCAL buffer AS STRING
 
  buffer = STRING$(LEN(d) * 2, 0)
 
  MultiByteToWideChar %CP_ACP, %NULL, BYVAL STRPTR(d), -1, BYVAL STRPTR(buffer), LEN(buffer)
  IF ISFALSE(VarDateFromStr(BYVAL STRPTR(buffer), 0, 0, vbdate)) THEN
    FUNCTION = vbdate
  END IF
 
END FUNCTION
 
'------------------------------------------------------------------------------
' Convert a VB date into a string
'
FUNCTION VbDateToStr(BYVAL vbdate AS DOUBLE) AS STRING
 
  LOCAL d  AS ASCIIZ * 64
  LOCAL dt AS STRING
  LOCAL st AS SYSTEMTIME
 
  VariantTimeToSystemTime vbdate, st
  GetDateFormat 0, 1, st, BYVAL %NULL, d, 64
 
  dt = d
 
  GetTimeFormat 0, 12, st, BYVAL %NULL, d, 64
  dt = dt & " " & d
 
  FUNCTION = dt
 
END FUNCTION
 
'------------------------------------------------------------------------------
' Return the number of days in a month (does not take leap years into account)
'
FUNCTION DaysInMonth(BYVAL m AS LONG) AS LONG
 
  FUNCTION = ASC(CHR$(31,28,31,30,31,30,31,31,30,31,30,31), m)
 
END FUNCTION
 
'------------------------------------------------------------------------------
' Return a GMT based time string compatible with the internet
'
FUNCTION InetTime() AS STRING
 
  LOCAL tz AS TIME_ZONE_INFORMATION
  LOCAL d  AS ASCIIZ * 64
  LOCAL t  AS ASCIIZ * 64
  LOCAL z  AS STRING
 
  GetDateFormat %LANG_ENGLISH, %NULL, BYVAL %NULL, "ddd',' d MMM yyyy", d, 64
  GetTimeFormat %LOCALE_USER_DEFAULT, %NULL, BYVAL %NULL, "HH':'mm':'ss", t, 64
 
  GetTimeZoneInformation tz
 
  IF tz.bias < 0 THEN
    tz.bias = ABS(tz.bias)
    z = ""
  ELSE
    z = "-"
  END IF
 
  tz.bias = (tz.bias \ 60) * 100 + (tz.bias MOD 60)
  z = z & FORMAT$(tz.bias, "0000")
 
  FUNCTION = d & " " & t & " " & z
 
END FUNCTION
