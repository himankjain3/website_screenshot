##Take Website Screenshot
##Made By - Himank Jain


# Read Website URL

echo "Enter you website url"
read website

echo "Please wait while we take a screenshot of your page"


# Spawning Instances

instance1=$(aws ec2 run-instances --image-id ami-0e9182bc6494264a4 --count 1 --instance-type t2.nano --key-name himank --security-group-ids sg-051e14874250c3929 --subnet-id subnet-6ec28106 --profile himank --region ap-south-1 --query "Instances[].InstanceId" --output text)

instance2=$(aws ec2 run-instances --image-id ami-0e9182bc6494264a4 --count 1 --instance-type t2.nano --key-name himank --security-group-ids sg-051e14874250c3929 --subnet-id subnet-3f823273 --profile himank --region ap-south-1 --query "Instances[].InstanceId" --output text)

instance_ip1=`aws ec2 describe-instances --instance-ids ${instance1} --region ap-south-1 --query "Reservations[].Instances[].PublicIpAddress" --output text --profile himank`
instance_ip2=`aws ec2 describe-instances --instance-ids ${instance2} --region ap-south-1 --query "Reservations[].Instances[].PublicIpAddress" --output text --profile himank`

sleep 30

# Taking Screenshot using remote ssh

command ssh -o StrictHostKeyChecking=no -i "/Users/himank/Downloads/himank.pem" ubuntu@${instance_ip1} "sudo apt-get update > /dev/null && sudo apt-get install -y xvfb wkhtmltopdf > /dev/null 2>&1 && xvfb-run --server-args='-screen 0, 1024x768x24' wkhtmltoimage --custom-header-propagation --custom-header User-Agent 'Mozilla/5.0 (X11; Linux x86_64; rv:50.0) Gecko/20100101 Firefox/50.0' ${website} firefox_${website}.jpg > /dev/null"

command ssh -o StrictHostKeyChecking=no -i "/Users/himank/Downloads/himank.pem" ubuntu@${instance_ip2} "sudo apt-get update > /dev/null && sudo apt-get install -y xvfb wkhtmltopdf > /dev/null 2>&1 && xvfb-run --server-args='-screen 0, 1024x768x24' wkhtmltoimage --custom-header-propagation --custom-header User-Agent 'Mozilla/5.0 (Linux; Android 10; SM-A102U) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.101 Mobile Safari/537.36.' ${website} chrome_${website}.jpg > /dev/null"

command scp -o StrictHostKeyChecking=no -i "/Users/himank/Downloads/himank.pem" ubuntu@${instance_ip1}:~/firefox_${website}.jpg . > /dev/null
command scp -o StrictHostKeyChecking=no -i "/Users/himank/Downloads/himank.pem" ubuntu@${instance_ip2}:~/chrome_${website}.jpg . > /dev/null


# Moving files to S3 bucket

aws s3 cp chrome_${website}.jpg s3://website-ss/Images/chrome_${website}.jpg --profile himank > /dev/null
aws s3 cp firefox_${website}.jpg s3://website-ss/Images/firefox_${website}.jpg --profile himank > /dev/null

echo "Please find the presigned urls for the screenshot"

# Getting signed urls for screenshots

aws s3 presign s3://website-ss/Images/chrome_${website}.jpg --expires-in 1800 --region us-east-1 --profile himank
aws s3 presign s3://website-ss/Images/firefox_${website}.jpg --expires-in 1800 --region us-east-1 --profile himank

