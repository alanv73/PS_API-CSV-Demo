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
    if ($null -eq $Object) {
        Write-Host "Nothing Loaded"
        return $null
    }

    do {
        $filename = Read-Host "Filename"
    } while ($null -eq $filename)

    if ($filename -notmatch ".csv$") {
        $filename += ".csv"
    }

    try {
        $Object | Export-CSV -Path $filename -NoTypeInformation
        Write-Host "$filename saved"
        Invoke-Item $filename
    } catch {
        Write-Host "File Save Error: $_"
    }
}

function LoadFromCSV() {
    do {
        $filename = Read-Host "Filename"
    } while ($null -eq $filename)

    if ($filename -notmatch ".csv$") {
        $filename += ".csv"
    }
    
    try {
        $data = Import-CSV -Path $filename
        $posts = @()

        foreach ($datum in $data) {
            $post = [Post]::fromJSON($datum)
            $posts += $post
        }

        Write-Host "Loaded $filename"
        $posts | Out-GridView -Title "$($posts.count) Posts Loaded from CSV file" -Wait
    } catch {
        Write-Host "File Load Error: $_"
    }

    return $posts
}

function showPosts($Posts) {
    if ($null -eq $Posts) {
        Write-Host "Nothing Loaded"
        return $null
    }

    $Posts | Out-GridView -Title "Posts" -Wait
}

function MainMenu($Message) {
    Clear-Host
    Write-Host "`n`t==={ Main Menu }==="
    Write-Host "`n`t1) Load Posts from API (GET)"
    Write-Host "`n`t2) Save a Post to API (POST)"
    Write-Host "`n`t3) Save Posts to CSV file"
    Write-Host "`n`t4) Load Posts from CSV file"
    Write-Host "`n`t5) Display Posts"
    Write-Host "`n`tQ) Quit"
    Write-Host "`n`n`tMake a selection:"
    Write-Host "`n`n`t$Message"
    if ($null -eq $dataObject) {
        Write-Host "`n`tNo Posts Loaded"
    }
    $Message = ""

    switch ($Host.UI.ReadLine()) {
        1 { $dataObject = GetFromAPI }
        2 { PostToAPI($dataObject) }
        3 { SaveToCSV($dataObject) }
        4 { $dataObject = LoadFromCSV }
        5 { showPosts($dataObject) }
        "Q" { exit }
        default { $Message = "Error: Invalid Choice" }
    }
    Write-Host -NoNewLine 'Press any key to continue...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    MainMenu($Message)
}

MainMenu