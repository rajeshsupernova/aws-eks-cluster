$token = Read-Host "Enter MFA Token"
$response = aws sts get-session-token --serial-number arn:aws:iam::xxxxxxxxxxxxx:mfa/GA-Iphone14ProMax --token-code $token --duration-seconds 129600 |ConvertFrom-Json
$env:AWS_ACCESS_KEY_ID = $response.Credentials.AccessKeyId
$env:AWS_SECRET_ACCESS_KEY =$response.Credentials.SecretAccessKey
$env:AWS_SESSION_TOKEN =$response.Credentials.SessionToken