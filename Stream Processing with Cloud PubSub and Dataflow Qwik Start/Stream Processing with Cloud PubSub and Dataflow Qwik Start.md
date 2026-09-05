# Stream Processing with Cloud Pub/Sub and Dataflow: Qwik Start || [GSP903](https://www.cloudskillsboost.google/focuses/18457?parent=catalog) ||

## Solution [here](https://youtu.be/yt181cgOEt8)

### Run the following Commands in CloudShell

```
export REGION=
```
```
curl -LO raw.githubusercontent.com/imharshtiwari/2-Minutes-GCP-Lab-Solutions/main/Stream%20Processing%20with%20Cloud%20PubSub%20and%20Dataflow%20Qwik%20Start/gsp903.sh

sudo chmod +x gsp903.sh

./gsp903.sh
```
```
docker run -it -e DEVSHELL_PROJECT_ID=$DEVSHELL_PROJECT_ID python:3.7 /bin/bash
```
```
git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git
```
```
cd python-docs-samples/pubsub/streaming-analytics
```
```
pip install -U -r requirements.txt  # Install Apache Beam dependencies
```
```
pip install "apache-beam[gcp]==2.48.0"
```




```
python PubSubToGCS.py \
    --project=project_id \
    --region=region \
    --input_topic=projects/project_id/topics/my-id \
    --output_path=gs://bucket_name/samples/output \
    --runner=DataflowRunner \
    --window_size=2 \
    --num_shards=2 \
    --temp_location=gs://bucket_name/temp \
    --worker_disk_type=compute.googleapis.com/projects/project_id/zones/zone/diskTypes/pd-standard \
    --worker_machine_type=e2-standard-2
```


#### Don't Forget to Join the [Telegram Channel](https://t.me/cloudwalabanda) & [Discussion group](https://t.me/cloudwalabandachats)

# [Cloud Wala Banda](https://www.youtube.com/@cloudwalabanda)
