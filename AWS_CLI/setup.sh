# Autor: Alen Cehic, Matthias Hug
# Datum: 07.12.2023
# Skript zur Erstellung der Lambda Funktionen und der Buckets

bucket_name_input=""
bucket_name_output=""
resize_percent=0

arn=$(aws sts get-caller-identity --query "Account" --output text)

while true; do
    echo ""
    echo "Namen des Buckets fuer originales Bild eingeben (kleinbuchstaben): "
    read bucket_name_input

    result=$(aws s3api head-bucket --bucket $bucket_name_input 2>&1)


    sed -i "s/ACCOUNT_ID/$arn/g" ./configs/notification.json

    if [[ $result == *"Not Found"* ]]; then
        echo ""
        echo "Bucket $bucket_name_input ist verfuegbar"
        echo ""
        echo "bitte warten"
        echo ""
        echo "-------------------------"
        echo ""
        aws s3api create-bucket --bucket "$bucket_name_input" --region us-east-1
        echo "-------------------------"
        break
    else
        echo "Bucket $bucket_name_input ist nicht verfuegbar, bitte erneut versuchen"
        echo ""
        echo "-------------------------"
    fi
done

while true; do
    echo "Bucketnamen für verkleinertes Bild angeben (kleinbuchstaben): "
    read bucket_name_output

    result=$(aws s3api head-bucket --bucket $bucket_name_output 2>&1)

    if [[ $result == *"not Found"* ]]; then
        echo ""
        echo "Bucket $bucket_name_output ist verfuegbar"
        echo ""
        echo "bitte warten"
        echo ""
        echo "------------------------"
        echo ""
        aws s3api create-bucket --bucket "$bucket_name_output" --region us-east-1
        echo "------------------------"
        break
    else
        echo "Bucket $bucket_name_output not avaiable, try again"
        echo ""
        echo "------------------------"
        echo ""
    fi
done

while true; do
    read -p "Prozentsatz fuer Verkleinerung angeben (ganze Zahl, kein Prozentzeichen): " resize_percent

    if [[ $resize_percent =~ ^[0-9]+$ ]]; then
        echo "$resize_percent% eingegeben."
        break
    else
        echo "Fehler: Prozentsatz nicht gültig."
    fi
done

aws lambda delte-function --function-name smallImage

aws lambda create-function --function-name smallImage --runtime nodejs18.x --role arn:aws:iam::$arn:role/LabRole --handler lambdaScript.handler --zip-file fileb://.lambdaScript.zip --memory-size 256

aws lambda add-permission --function-name smallImage --action "lambda:InvokeFunction" --principal s3.amazon.com --source-arn arn:aws:s3:::$bucket_name_input --statement-id "$bucket_name_input"

aws s3api put-bucket-notification-configuration --bucket "$bucket_name_input" --notification-configuration '{
    "LambdaFunctionConfigurations": [
        {
            "LambdaFunctionArn": "arn:aws:lambda:us-east-1:'$arn':function:smallImage",
            "Events": [
                "s3:ObjectCreated:Put"
            ]
        }
    ]
}'

aws lambda update-function-configuration --function-name smallImage --environment "Variables={bucket_name_input=$bucket_name_input,bucket_name_output=$bucket_name_output,resize_percent=$resize_percent}" --query "Environment"

aws s3 cp ./testimage/enchantments.png s3://$bucket_name_input/enchantments.png

latest_image=$(aws s3 ls s3://$bucket_name_output --recursive | sort | tail -n 1 | awk '{print $4}')

echo "Das Bild kann gefunden werden unter: blabla"

aws s3 cp s3://$bucket_name_output/$latest_image #pathToOutput