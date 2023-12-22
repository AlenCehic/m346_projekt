BUCKET_NAME_ORIGINAL="mhgoriginal6gbssg"
BUCKET_NAME_COMPRESSED="mhgverkleinert6gbssg"
aws s3 cp ./testimage/placeholder-gbs.png s3://$BUCKET_NAME_ORIGINAL/placeholder-gbs.png > /dev/null 2>&1

sleep 10
LATEST_IMAGE=$(aws s3 ls s3://$BUCKET_NAME_COMPRESSED --recursive | sort | tail -n 1 | awk '{print $4}')
echo $LATEST_IMAGE
aws s3 cp s3://$BUCKET_NAME_COMPRESSED/$LATEST_IMAGE "./testImage.png"

echo "Das Bild kann gefunden werden unter: home"