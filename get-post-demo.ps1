using module .\Post.psm1

$API_URL = "https://jsonplaceholder.typicode.com/posts"

function GetFromAPI() {
    $url = $API_URL
    $PostsArray = @()
    
    try {
        $posts = Invoke-RestMethod $url -Method Get

        foreach ($post in $posts) {
            $PostsArray += [Post]::fromJSON($post)
        }

        $PostsArray | Out-GridView

        return $PostsArray
    } catch {
        Write-Host "GET Error: $_"
    }
}

function PostToAPI($Object) {
    Write-Host $Object
}

function SaveToCSV($Object) {
    $filename = Read-Host "Filename"
    Write-Host "$filename saved"
}

function LoadFromCSV() {
    $filename = Read-Host "Filename"
    Write-Host "Loaded $filename"
}

function MainMenu($Message) {
    Clear-Host
    Write-Host "==={ Main Menu }==="
    Write-Host "Make a selection:"
    Write-Host "1) GET Data from API"
    Write-Host "2) POST Data to API"
    Write-Host "3) Save Data to CSV"
    Write-Host "4) Load Data from CSV"
    Write-Host "Q) Quit"
    Write-Host "`n$Message"
    $Message = ""

    switch (Read-Host) {
        1 { $dataObject = GetFromAPI }
        2 { PostToAPI -Object $dataObject }
        3 { SaveToCSV -Object $dataObject }
        4 { LoadFromCSV }
        "Q" { exit }
        default { $Message = "Error: Invalid Choice" }
    }
    Write-Host -NoNewLine 'Press any key to continue...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    MainMenu($Message)
}

MainMenu