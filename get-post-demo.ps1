using module .\Post.psm1

$API_BASE_URL = "https://jsonplaceholder.typicode.com"

function GetFromAPI() {
    $url = "$API_BASE_URL/posts"
    $PostsArray = @()
    
    try {
        $posts = Invoke-RestMethod $url -Method Get

        foreach ($post in $posts) {
            $PostsArray += [Post]::fromJSON($post)
        }

        Write-Host "$($PostsArray.count) Posts Loaded from API"
        $PostsArray | Out-GridView -Title "Posts from API" -Wait

        return $PostsArray
    } catch {
        Write-Host "GET Error: $_"
    }
}

function PostToAPI($Object) {
    if ($null -eq $Object) {
        Write-Host "Nothing Loaded"
        return $null
    }

    $url = "$API_BASE_URL/posts"

    $post = $Object | Out-GridView -Title "Select a Record to POST" -PassThru

    if ($null -eq $post) {
        Write-Host "No Record Selected"
        return $null
    }

    $headers = New-Object System.Collections.Generic.Dictionary"[[String],[String]]"
    $headers.add("Content-type", "application/json; charset=UTF-8")

    $body = $post.toJSONString()

    try {
        $response = Invoke-RestMethod $url -Method Post -Headers $headers -Body $body
        Write-Host "Record id: $($post.id) POSTed to API"
        $response | Out-GridView -Title "Record POSTed" -Wait
    } catch {
        Write-Host "POST Error: $_"
    }
    
}

function SaveToCSV($Object) {
    $filename = Read-Host "Filename"
    $Object | Export-CSV -Path $filename -NoTypeInformation
    Write-Host "$filename saved"
    Invoke-Item $filename
}

function LoadFromCSV() {
    $filename = Read-Host "Filename"
    $data = Import-CSV -Path $filename
    $posts = @()

    foreach ($datum in $data) {
        $post = [Post]::fromJSON($datum)
        $posts += $post
    }

    Write-Host "Loaded $filename"
    $posts | Out-GridView -Title "Posts Loaded from CSV file" -Wait
}

function MainMenu($Message) {
    Clear-Host
    Write-Host "==={ Main Menu }==="
    Write-Host "`n1) GET Data from API"
    Write-Host "2) POST Data to API"
    Write-Host "3) Save Data to CSV"
    Write-Host "4) Load Data from CSV"
    Write-Host "Q) Quit"
    Write-Host "`nMake a selection:"
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