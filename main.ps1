$http = [System.Net.HttpListener]::new() 
$http.Prefixes.Add("http://localhost:8080/")
$http.Start()


if ($http.IsListening) {
    write-host "Serving on $($http.Prefixes)" -f 'y'
}

function Handle-Index {
    param ($response)

    [string]$html = Get-Content "index.html" -Raw
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
    $response.ContentType  = "text/html"
    $response.ContentLength64 = $buffer.Length
    $response.OutputStream.Write($buffer, 0, $buffer.Length) 
    $response.OutputStream.Close()
}

while ($http.IsListening) {
    $context = $http.GetContext()
    $response = $context.Response

    if ($context.Request.HttpMethod -eq 'GET' -and $context.Request.RawUrl -eq '/') {
        Handle-Index $response
    }

    if ($context.Request.HttpMethod -eq 'POST' -and $context.Request.RawUrl -eq '/api/start') {
        $FormContent = [System.IO.StreamReader]::new($context.Request.InputStream).ReadToEnd()
        Write-Host $FormContent -f 'Green'

        $FormContent.Split("&") | ForEach-Object -Process {
            $name, $value = $_.Split("=")
            Write-Host $name -f 'Blue'
            Write-Host $value -f 'Red'
        }

        # do stuff
        
        Handle-Index $response
    }

} 
