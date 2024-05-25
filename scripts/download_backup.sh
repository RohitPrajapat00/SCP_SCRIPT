# Navigate to the root of the SCP_SCRIPT directory
cd "$(dirname "$0")/.."

# Load environment variables from .env file
if [ -f .env ]; then
  echo "Loading environment variables from .env file..."
  export $(grep -v '^#' .env | xargs)
else
  echo ".env file not found!"
  exit 1
fi

# Define variables from .env file
PEM_FILE=$PEM_FILE
REMOTE_USER=$REMOTE_USER
REMOTE_HOST=$REMOTE_HOST
REMOTE_PATH=$REMOTE_PATH
LOCAL_PATH=$LOCAL_PATH

# Ensure the PEM file has the correct permissions
echo "Setting permissions for the PEM file..."
chmod 400 $PEM_FILE

# Check if PEM file exists
if [ ! -f $PEM_FILE ]; then
  echo "PEM file not found at $PEM_FILE"
  exit 1
fi

# Test connection to the server
echo "Testing connection to the server $REMOTE_USER@$REMOTE_HOST..."
ssh -i $PEM_FILE -o BatchMode=yes -o ConnectTimeout=5 $REMOTE_USER@$REMOTE_HOST 'exit'
if [ $? -eq 0 ]; then
  echo "Successfully connected to the server."
else
  echo "Failed to connect to the server. Please check your credentials and network connection."
  exit 1
fi

# Check if remote path exists
echo "Checking if the remote path $REMOTE_PATH exists..."
ssh -i $PEM_FILE $REMOTE_USER@$REMOTE_HOST "test -f $REMOTE_PATH"
if [ $? -eq 0 ]; then
  echo "Remote path exists. Starting download..."
else
  echo "Remote path does not exist: $REMOTE_PATH"
  exit 1
fi

# Run the SCP command
echo "Downloading backup from $REMOTE_PATH to $LOCAL_PATH..."
scp -i $PEM_FILE $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH $LOCAL_PATH

# Check if the SCP command was successful
if [ $? -eq 0 ]; then
  echo "Backup successfully downloaded to $LOCAL_PATH"
else
  echo "Failed to download backup"
fi
