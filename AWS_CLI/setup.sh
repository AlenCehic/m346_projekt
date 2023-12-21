# Autor: Alen Cehic, Matthias Hug
# Datum: 07.12.2023
# Skript zur Erstellung der Lambda Funktionen und der Buckets

if aws lambda get-function --function-name compressImage 2>/dev/null; then
    BUCKET_NAME_COMPRESSED=$(aws lambda get-function-configuration --function-name compressImage --query "Environment.Variables.BUCKET_NAME_COMPRESSED" --output text)
    BUCKET_NAME_ORIGINAL=$(aws lambda get-function-configuration --function-name compressImage --query "Environment.Variables.BUCKET_NAME_ORIGINAL" --output text)
fi

echo $BUCKET_NAME_COMPRESSED
echo $BUCKET_NAME_ORIGINAL
PERCENTAGE_RESIZE=0

ARN=$(aws sts get-caller-identity --query "Account" --output text)

sed -i "s/ACCOUNT_ID/$ARN/g" ./configs/notification.json

function doAction() {
    
    case $1 in
    1)

        echo ""
        echo "Namen des neuen Buckets eingeben:"
        read BUCKET_NAME_ORIGINAL

        RESULT=$(aws s3api head-bucket --bucket $BUCKET_NAME_ORIGINAL 2>&1)

        if [[ $RESULT == *"Not Found"* ]]; then
            echo "Bucket $BUCKET_NAME_ORIGINAL ist verfuegbar"
            echo ""
            echo "--------------------"
            echo ""
            echo s3api create-bucket --bucket "$BUCKET_NAME_ORIGINAL" --region us-east-1
        
            NEW_ENVARS=$(aws lambda get-function-configuration --function-name compressImage --query "Environment.Variables | merge(@, \`{\"BUCKET_NAME_ORIGINAL\":\"$BUCKET_NAME_ORIGINAL\"}\`)")
            aws lambda update-function-configuration --function-name compressImage --environment "{ \"Variables\": $NEW_ENVARS }"

            echo "----------------------------------------"
        # $bucket="false"
        else
            echo "Bucket $BUCKET_NAME_ORIGINAL ist nicht verfuegbar"
            echo ""
            echo "------------------------"
        fi
        ;;
    2)
        echo ""
        echo "Name des neuen Buckets eingeben:"
        read BUCKET_NAME_COMPRESSED

        RESULT=$(aws s3api head-bucket --bucket $BUCKET_NAME_COMPRESSED 2>&1)

        if [[ $RESULT == *"Not Found"* ]]; then
            echo "Bucket $BUCKET_NAME_COMPRESSED ist verfuegbar"
            echo ""
            echo "-----------------------------"
            echo ""
            aws s3api create-bucket --bucket "$BUCKET_NAME_COMPRESSED" --region us-east-1

            # Aendert die Variable BUCKET_NAME_COMPRESSED in der lambda Funktion
            NEW_ENVVARS=$(aws lambda get-function-configuration --function-name compressImage --query "Environment.Variables | merge(@, \`{\"BUCKET_NAME_COMPRESSED\":\"$BUCKET_NAME_COMPRESSED\"}\`)")
            aws lambda update-function-configuration --function-name compressImage --environment "{ \"Variables\": $NEW_ENVVARS }"

            echo "-----------------------------"
            break
        else
            echo "Bucket $BUCKET_NAME_COMPRESSED ist nicht verfuegbar, bitte nochmals versuchen"
            echo ""
            echo "-----------------------------"
        fi
        ;;
    3)
        read -p "Geben Sie einen Prozentsatz fuer die Verkleinerung des Bildes ein (als ganze Zahl, ohne Prozentzeichen): " PERCENTAGE_RESIZE

        if [[ $PERCENTAGE_RESIZE =~ ^[0-9]+$ ]]; then
            echo "Sie haben $PERCENTAGE_RESIZE% eingegeben."
            NEW_ENVVARS=$(aws lambda get-function-configuration --function-name compressImage --query "Environment.Variables | merge(@, \`{\"PERCENTAGE_RESIZE\":\"$PERCENTAGE_RESIZE\"}\`)")
            aws lambda update-function-configuration --function-name compressImage --environment "{ \"Variables\": $NEW_ENVVARS }"
            break
        else
            echo "Fehler: Sie haben keinen gültigen Prozentsatz eingegeben."
        fi
        ;;
    4)
        echo "Ende"
        exit 0
        ;;
    5)
        # Löscht alle Buckets
        aws s3 ls | awk '{print $3}' | while read bucket; do
            echo "Deleting bucket $bucket"
            aws s3 rb s3://$bucket --force
            aws lambda update-function-configuration --function-name compressImage --environment "Variables={BUCKET_NAME_ORIGINAL=}"
            aws lambda update-function-configuration --function-name compressImage --environment "Variables={BUCKET_NAME_COMPRESSED=}"
            echo "Welche Aktion soll durchgefuehrt werden?"
            echo "1. Neu Aufsetzen"
            echo "2. Exit"
            echo "------------------------------"
            echo -n "Nummer Waehlen: "
            read postDelete

            case $1 in
            1)
                break
                ;;
            2)
                echo "Ende"
                exit 0
                ;;
            *)
                echo "Ungueltige Auswahl, erneut eingeben: "
                ;;
            esac

        done
        ;;
    *)
        # Invalid selection
        echo "Ungueltige Auswahl wähle erneut: "
        ;;
    esac
}

# Menu
while [[ "$BUCKET_NAME_ORIGINAL" != "" && "$BUCKET_NAME_COMPRESSED" != "" ]]; do
    echo "Welche Aktion soll durchgefuehrt werden?:"
    echo "1. Bucket für upload aendern"
    echo "2. Bucket für download aendern"
    echo "3. Skallierung aendern"
    echo "4. Exit"
    echo "5. Alle Buckets loeschen"
    echo "------------------------------------------"
    echo -n "Nummer Wählen: "
    read action

    doAction "$action"
done

while [[ "$BUCKET_NAME_ORIGINAL" == "" ]]; do
    echo ""
    echo "Namen des Buckets fuer originales Bild eingeben (kleinbuchstaben): "
    read BUCKET_NAME_ORIGINAL

    RESULT=$(aws s3api head-bucket --bucket $BUCKET_NAME_ORIGINAL 2>&1)


    sed -i "s/ACCOUNT_ID/$ARN/g" ./configs/notification.json

    if [[ $RESULT == *"Not Found"* ]]; then
        echo ""
        echo "Bucket $BUCKET_NAME_ORIGINAL ist verfuegbar"
        echo ""
        echo "bitte warten"
        echo ""
        echo "-------------------------"
        echo ""
        echo "-------------------------"
        break
    else
        echo "Bucket $BUCKET_NAME_ORIGINAL ist nicht verfuegbar, bitte erneut versuchen"
        echo ""
        echo "-------------------------"
    fi
done

while [[ "$BUCKET_NAME_COMPRESSED" == "" ]]; do
    echo "Bucketnamen für verkleinertes Bild angeben (kleinbuchstaben): "
    read BUCKET_NAME_COMPRESSED

    RESULT=$(aws s3api head-bucket --bucket $BUCKET_NAME_COMPRESSED 2>&1)

    if [[ $RESULT == *"Not Found"* ]]; then
        echo ""
        echo "Bucket $BUCKET_NAME_COMPRESSED ist verfuegbar"
        echo ""
        echo "bitte warten"
        echo ""
        echo "------------------------"
        echo ""
        echo "------------------------"
        break
    else
        echo "Bucket $BUCKET_NAME_COMPRESSED not avaiable, try again"
        echo ""
        echo "------------------------"
        echo ""
    fi
done

while [[ ! "$PERCENTAGE_RESIZE" ]]; do
    read -p "Prozentsatz fuer Verkleinerung angeben (ganze Zahl, kein Prozentzeichen): " PERCENTAGE_RESIZE

    if [[ $PERCENTAGE_RESIZE =~ ^[0-9]+$ ]]; then
        echo "$PERCENTAGE_RESIZE% eingegeben."
        break
    else
        echo "Fehler: Prozentsatz nicht gültig."
    fi
done

aws s3api create-bucket --bucket "$BUCKET_NAME_COMPRESSED" --region us-east-1

aws s3api create-bucket --bucket "$BUCKET_NAME_ORIGINAL" --region us-east-1

if aws lambda get-function --function-name compressImage 2>/dev/null; then

    aws lambda delete-function --function-name compressImage

    aws lambda create-function --function-name compressImage --runtime nodejs18.x --role ARN:aws:iam::$ARN:role/LabRole --handler lambdaScript.handler --zip-file fileb://.lambdaScript.zip --memory-size 256

    aws lambda add-permission --function-name compressImage --action "lambda:InvokeFunction" --principal s3.amazon.com --source-ARN ARN:aws:s3:::$BUCKET_NAME_ORIGINAL --statement-id "$BUCKET_NAME_ORIGINAL"

    aws s3api put-bucket-notification-configuration --bucket "$BUCKET_NAME_ORIGINAL" --notification-configuration '{
        "LambdaFunctionConfigurations": [
            {
                "LambdaFunctionARN": "ARN:aws:lambda:us-east-1:'$ARN':function:compressImage",
                "Events": [
                    "s3:ObjectCreated:Put"
                ]
            }
        ]
    }'

fi
    
aws lambda update-function-configuration --function-name compressImage --environment "Variables={BUCKET_NAME_ORIGINAL=$BUCKET_NAME_ORIGINAL,BUCKET_NAME_COMPRESSED=$BUCKET_NAME_COMPRESSED,PERCENTAGE_RESIZE=$PERCENTAGE_RESIZE}" --query "Environment"

aws s3 cp ./testimage/enchantments.png s3://$BUCKET_NAME_ORIGINAL/enchantments.png

LATEST_IMAGE=$(aws s3 ls s3://$BUCKET_NAME_COMPRESSED --recursive | sort | tail -n 1 | awk '{print $4}')

echo "Das Bild kann gefunden werden unter: blabla"

aws s3 cp s3://$BUCKET_NAME_COMPRESSED/$LATEST_IMAGE #pathToOutput