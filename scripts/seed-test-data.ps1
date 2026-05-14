# Seed synthetic test data into the SFTS sandbox.
# All records are clearly marked SYNTHETIC for easy identification and cleanup.
# Re-runnable: existing SYNTHETIC records are deleted first.
#
# Usage:  pwsh ./scripts/seed-test-data.ps1
# Target: whatever sfts-dev is set to in sf config

$ErrorActionPreference = "Stop"

Write-Host "=== Cleaning up any prior SYNTHETIC test data ==="
# Order matters: delete children before parents
"Hotline_Call__c", "Shelter_Stay__c", "Mandatory_Report__c", "Danger_Assessment__c" | ForEach-Object {
    $obj = $_
    sf data query --query "SELECT Id FROM $obj WHERE Name LIKE '%SYNTHETIC%' OR Outcome_Notes__c LIKE '%SYNTHETIC%' OR Notes__c LIKE '%SYNTHETIC%' OR Subject_Description__c LIKE '%SYNTHETIC%'" --json 2>$null |
        ConvertFrom-Json |
        ForEach-Object { $_.result.records } |
        ForEach-Object { if ($_) { sf data delete record --sobject $obj --record-id $_.Id | Out-Null } }
}
sf data query --query "SELECT Id FROM Contact WHERE LastName LIKE '%Test%' AND FirstName LIKE 'SYN%'" --json 2>$null |
    ConvertFrom-Json |
    ForEach-Object { $_.result.records } |
    ForEach-Object { if ($_) { sf data delete record --sobject Contact --record-id $_.Id | Out-Null } }

Write-Host ""
Write-Host "=== Creating 5 synthetic Contacts ==="
$contacts = @(
    @{FN='SYN_Jane';    LN='Test_Smith';   County='Marion';   Phone='317-555-0101'; ACP=$false; Lang='English'},
    @{FN='SYN_Maria';   LN='Test_Garcia';  County='Marion';   Phone='317-555-0102'; ACP=$true;  Lang='Spanish'},
    @{FN='SYN_Sarah';   LN='Test_Johnson'; County='Shelby';   Phone='317-555-0103'; ACP=$false; Lang='English'},
    @{FN='SYN_Lily';    LN='Test_Lee';     County='Johnson';  Phone='317-555-0104'; ACP=$false; Lang='English'},
    @{FN='SYN_Diana';   LN='Test_Patel';   County='Hancock';  Phone='317-555-0105'; ACP=$true;  Lang='English'}
)
$contactIds = @{}
foreach ($c in $contacts) {
    $r = sf data create record --sobject Contact --values "FirstName='$($c.FN)' LastName='$($c.LN)' Phone='$($c.Phone)' Indiana_County_of_Residence__c=$($c.County) Indiana_ACP_Enrolled__c=$($c.ACP) Primary_Language__c='$($c.Lang)'" --json | ConvertFrom-Json
    $contactIds[$c.FN] = $r.result.id
    Write-Host "  Created Contact: $($c.FN) $($c.LN) ($($c.County) County)"
}

Write-Host ""
Write-Host "=== Creating 15 synthetic Hotline Calls ==="
function NowMinus([int]$days) { return (Get-Date).AddDays(-$days).ToString('yyyy-MM-ddTHH:mm:ssZ') }
$calls = @(
    @{Contact=$contactIds['SYN_Jane'];  Days=1;  CType='Survivor'; CallType='Crisis';          Issue='Domestic Violence'; Outcome='Safety Plan Created';   Imm=$true;  County='Marion'},
    @{Contact=$contactIds['SYN_Jane'];  Days=5;  CType='Survivor'; CallType='Shelter Inquiry'; Issue='Domestic Violence'; Outcome='Shelter Admitted';      Imm=$false; County='Marion'},
    @{Contact=$contactIds['SYN_Maria']; Days=2;  CType='Survivor'; CallType='Crisis';          Issue='Domestic Violence'; Outcome='Information Provided';  Imm=$false; County='Marion'},
    @{Contact=$contactIds['SYN_Sarah']; Days=3;  CType='Survivor'; CallType='Crisis';          Issue='Sexual Assault';    Outcome='Referral Made';         Imm=$true;  County='Shelby'},
    @{Contact=$contactIds['SYN_Sarah']; Days=10; CType='Survivor'; CallType='Information Only'; Issue='Domestic Violence'; Outcome='Information Provided';  Imm=$false; County='Shelby'},
    @{Contact=$contactIds['SYN_Lily'];  Days=7;  CType='Survivor'; CallType='Crisis';          Issue='Stalking';          Outcome='Safety Plan Created';   Imm=$true;  County='Johnson'},
    @{Contact=$contactIds['SYN_Diana']; Days=14; CType='Survivor'; CallType='Crisis';          Issue='Domestic Violence'; Outcome='Shelter Admitted';      Imm=$true;  County='Hancock'},
    @{Contact=$null;                    Days=8;  CType='Survivor'; CallType='Crisis';          Issue='Domestic Violence'; Outcome='Information Provided';  Imm=$false; County='Marion'},
    @{Contact=$null;                    Days=12; CType='Concerned Person'; CallType='Information Only'; Issue='Domestic Violence'; Outcome='Information Provided'; Imm=$false; County='Marion'},
    @{Contact=$null;                    Days=20; CType='Hangup';   CallType='Other';           Issue='Other';             Outcome='Hung Up';               Imm=$false; County='Unknown'},
    @{Contact=$null;                    Days=25; CType='Professional'; CallType='Referral';    Issue='Domestic Violence'; Outcome='Referral Made';         Imm=$false; County='Marion'},
    @{Contact=$null;                    Days=30; CType='Survivor'; CallType='Crisis';          Issue='Human Trafficking'; Outcome='Mandatory Report Filed'; Imm=$true;  County='Marion'},
    @{Contact=$null;                    Days=45; CType='Concerned Person'; CallType='Information Only'; Issue='Teen Dating Violence'; Outcome='Information Provided'; Imm=$false; County='Hamilton'},
    @{Contact=$null;                    Days=60; CType='Survivor'; CallType='Shelter Inquiry'; Issue='Domestic Violence'; Outcome='Information Provided';  Imm=$false; County='Out of State'},
    @{Contact=$null;                    Days=90; CType='Survivor'; CallType='Crisis';          Issue='Domestic Violence'; Outcome='Safety Plan Created';   Imm=$false; County='Marion'}
)
foreach ($call in $calls) {
    $start = NowMinus($call.Days)
    $vals = "Call_Start_DateTime__c=$start Caller_Type__c='$($call.CType)' Call_Type__c='$($call.CallType)' Primary_Issue__c='$($call.Issue)' Outcome__c='$($call.Outcome)' Imminent_Danger_Indicated__c=$($call.Imm) Caller_County__c='$($call.County)' Outcome_Notes__c='SYNTHETIC test call'"
    if ($call.Contact) { $vals += " Contact__c=$($call.Contact)" }
    sf data create record --sobject Hotline_Call__c --values $vals | Out-Null
}
Write-Host "  Created 15 Hotline Calls (mix of dates, outcomes, danger flags)"

Write-Host ""
Write-Host "=== Creating 4 synthetic Shelter Stays ==="
# 2 currently in shelter, 2 exited
sf data create record --sobject Shelter_Stay__c --values "Contact__c=$($contactIds['SYN_Jane']) Check_In_DateTime__c=$(NowMinus(4)) Status__c=Active Number_of_Adults__c=1 Number_of_Children__c=2 Pets__c=Dog Notes__c='SYNTHETIC active stay'" | Out-Null
sf data create record --sobject Shelter_Stay__c --values "Contact__c=$($contactIds['SYN_Diana']) Check_In_DateTime__c=$(NowMinus(13)) Status__c=Active Number_of_Adults__c=1 Number_of_Children__c=0 Pets__c=None Notes__c='SYNTHETIC active stay'" | Out-Null
sf data create record --sobject Shelter_Stay__c --values "Contact__c=$($contactIds['SYN_Maria']) Check_In_DateTime__c=$(NowMinus(35)) Check_Out_DateTime__c=$(NowMinus(20)) Status__c=Exited Number_of_Adults__c=1 Number_of_Children__c=1 Exit_Destination__c='Own Apartment or House' Exit_Reason__c='Goals Met' Notes__c='SYNTHETIC exited stay'" | Out-Null
sf data create record --sobject Shelter_Stay__c --values "Contact__c=$($contactIds['SYN_Sarah']) Check_In_DateTime__c=$(NowMinus(80)) Check_Out_DateTime__c=$(NowMinus(65)) Status__c=Exited Number_of_Adults__c=1 Number_of_Children__c=0 Exit_Destination__c='Family' Exit_Reason__c='Voluntary Early Exit' Notes__c='SYNTHETIC exited stay'" | Out-Null
Write-Host "  Created 4 Shelter Stays (2 active, 2 exited)"

Write-Host ""
Write-Host "=== Creating 3 synthetic Danger Assessments ==="
# One severe, one increased, one variable
sf data create record --sobject Danger_Assessment__c --values "Contact__c=$($contactIds['SYN_Jane']) Assessment_DateTime__c=$(NowMinus(3)) Q01_Violence_Increased__c=Yes Q02_Owns_Gun__c=Yes Q05_Weapon_Threatened__c=Yes Q06_Threatens_To_Kill__c=Yes Q09_Forced_Sex__c=Yes Q10_Strangled__c=Yes Q13_Controls_Daily__c=Yes Q14_Jealous__c=Yes Q17_Threatens_Children__c=Yes Q18_Capable_Of_Killing__c=Yes Q19_Stalking__c=Yes Q03_You_Left__c=Yes Q12_Alcoholic__c=Yes Q15_Beaten_Pregnant__c=Yes Notes__c='SYNTHETIC severe-risk assessment, 14 Yes answers'" | Out-Null
sf data create record --sobject Danger_Assessment__c --values "Contact__c=$($contactIds['SYN_Diana']) Assessment_DateTime__c=$(NowMinus(13)) Q01_Violence_Increased__c=Yes Q06_Threatens_To_Kill__c=Yes Q10_Strangled__c=Yes Q13_Controls_Daily__c=Yes Q14_Jealous__c=Yes Q18_Capable_Of_Killing__c=Yes Q19_Stalking__c=Yes Q11_Illegal_Drugs__c=Yes Notes__c='SYNTHETIC increased-risk assessment, 8 Yes answers'" | Out-Null
sf data create record --sobject Danger_Assessment__c --values "Contact__c=$($contactIds['SYN_Sarah']) Assessment_DateTime__c=$(NowMinus(78)) Q01_Violence_Increased__c=Yes Q14_Jealous__c=Yes Q13_Controls_Daily__c=Yes Notes__c='SYNTHETIC variable-risk assessment, 3 Yes answers'" | Out-Null
Write-Host "  Created 3 Danger Assessments (Severe, Increased, Variable tiers)"

Write-Host ""
Write-Host "=== Creating 1 synthetic Mandatory Report ==="
sf data create record --sobject Mandatory_Report__c --values "Report_Type__c=DCS Report_DateTime__c=$(NowMinus(30)) About_Contact__c=$($contactIds['SYN_Lily']) Reporting_Agency_Name__c='Indiana DCS Hotline' Method__c=Phone Triggering_Event__c='SYNTHETIC: child observed at intake with visible injury' Narrative__c='SYNTHETIC test report. DO NOT TREAT AS REAL.' Outcome_Status__c='Investigation Opened'" | Out-Null
Write-Host "  Created 1 Mandatory Report"

Write-Host ""
Write-Host "=== Final counts ==="
"Contact (SYN)", "Hotline_Call__c", "Shelter_Stay__c", "Danger_Assessment__c", "Mandatory_Report__c" | ForEach-Object {
    $obj = $_
    if ($obj -eq "Contact (SYN)") {
        sf data query --query "SELECT COUNT() FROM Contact WHERE FirstName LIKE 'SYN%'"
    } else {
        sf data query --query "SELECT COUNT() FROM $obj"
    }
}

Write-Host ""
Write-Host "Done. To clean up: re-run this script (it deletes prior SYNTHETIC data first)."
