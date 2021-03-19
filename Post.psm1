class Post {
    [int]$id
    [string]$title
    [string]$body
    [int]$userId

    Post(
        [int]$id,
        [string]$title,
        [string]$body,
        [int]$userId
    ) {
        $this.id = $id
        $this.title = $title
        $this.body = $body
        $this.userId = $userId
    }

    static [Post]fromJSON($JsonData) {
        return New-Object Post(
            $JsonData.id,
            $JsonData.title,
            $JsonData.body,
            $JsonData.userId
        )
    }
}