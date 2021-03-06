using module .\Post.psm1

$API_BASE_URL = "https://jsonplaceholder.typicode.com"

function GetFromAPI() {
    $url = "$API_BASE_URL/posts"
    
    try {
        $posts = Invoke-RestMethod $url -Method Get

        $PostsArray = $posts.ForEach( { [Post]::fromJSON($_) })

        Write-Host "`n`t$($PostsArray.count) Posts Loaded from API"
        $PostsArray | Out-GridView -Title "Posts from API" -Wait

        return $PostsArray
    } catch {
        Write-Host "`n`tGET Error: $_"
    }
}

function PostToAPI($Object) {
    if ($null -eq $Object) {
        Write-Host "`n`tNothing Loaded"
        return $null
    }

    $url = "$API_BASE_URL/posts"

    do {
        $post = $Object | Out-GridView -Title "Select a Record to POST" -PassThru
        $wshell = New-Object -ComObject Wscript.Shell
        if ($null -eq $post) {
            $response = $wshell.Popup(
                'No record selected. Do you want to try again?', 
                0,
                'Nothing Selected', 
                0x4
            )
        } elseif ($post -is [Array]) {
            $response = $wshell.Popup(
                'Multiple records selected. Please try again.', 
                0,
                'Multiple Selection', 
                0x1
            )
        }
        switch ( $response) {
            { ($_ -eq 1) -or ($_ -eq 6) } { $post = $null } # OK or Yes
            { ($_ -eq 2) -or ($_ -eq 7) } { return $null } # Cancel or No
        }
    } while ($null -eq $post)

    if ($post -is [Array]) {
        Write-Host "`n`tMultiple items selected, using first selected item only"
        $post = $post[0]
    }

    $headers = New-Object System.Collections.Generic.Dictionary"[[String],[String]]"
    $headers.add("Content-type", "application/json; charset=UTF-8")

    $body = $post.toJSONString()

    try {
        $response = Invoke-RestMethod $url -Method Post -Headers $headers -Body $body
        Write-Host "`n`tRecord id: $($post.id) POSTed to API"
        $response | Out-GridView -Title "Record POSTed" -Wait
    } catch {
        Write-Host "`n`tPOST Error: $_"
    }
    
}

function SaveToCSV($Object) {
    if ($null -eq $Object) {
        Write-Host "`n`tNothing Loaded"
        return $null
    }

    do {
        $filename = Read-Host "`n`tFilename"
    } while ($null -eq $filename)

    if ($filename -notmatch ".csv$") {
        $filename += ".csv"
    }

    try {
        $Object | Export-CSV -Path $filename -NoTypeInformation
        Write-Host "`n`t$filename saved"
        Invoke-Item $filename
    } catch {
        Write-Host "`n`tFile Save Error: $_"
    }
}

function LoadFromCSV() {
    do {
        $filename = Read-Host "`n`tFilename"
    } while ($null -eq $filename)

    if ($filename -notmatch ".csv$") {
        $filename += ".csv"
    }
    
    try {
        $data = Import-CSV -Path $filename

        $posts = $data.ForEach( { [Post]::fromJSON($_) })

        Write-Host "`n`t$($posts.count) Posts Loaded from CSV file $filename"
        $posts | Out-GridView -Title "$($posts.count) Posts Loaded from CSV file" -Wait
    } catch {
        Write-Host "`n`tFile Load Error: $_"
    }

    return $posts
}

function showPosts($Posts) {
    if ($null -eq $Posts) {
        Write-Host "`n`tNothing Loaded"
        return $null
    }

    $Posts | Out-GridView -Title "Posts" -Wait
}

function MainMenu() {
    Clear-Host
    Write-Host "`n`t==={ Main Menu }==="
    Write-Host "`n`t1) Load Posts from API (GET)"
    Write-Host "`t2) Save a Post to API (POST)"
    Write-Host "`t3) Save Posts to CSV file"
    Write-Host "`t4) Load Posts from CSV file"
    Write-Host "`t5) Display Posts"
    Write-Host "`n`tQ) Quit"
    if ($null -eq $dataObject) {
        Write-Host "`n`tNo Posts Loaded"
    }
    # Write-Host "`n`n`tMake a selection:"

    switch (read-host "`n`n`tMake a selection") {
        1 { $dataObject = GetFromAPI }
        2 { PostToAPI($dataObject) }
        3 { SaveToCSV($dataObject) }
        4 { $dataObject = LoadFromCSV }
        5 { showPosts($dataObject) }
        "Q" { exit }
        default { Write-Host "`tError: Invalid Choice" }
    }
    Write-Host -NoNewLine "`n`tPress any key to continue...";
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    MainMenu
}

MainMenu