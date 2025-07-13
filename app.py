from flask import Flask, render_template, jsonify
import os
import json
import threading
import time
import subprocess
from datetime import datetime

app = Flask(__name__)
LOG_DIR = "session_logs"
DEVICE_PATH = "/sdcard/Android/data/com.example.dummy_bank/files"

# Ensure the session_logs folder exists
os.makedirs(LOG_DIR, exist_ok=True)

def log_message(message):
    """Helper function for logging with timestamps"""
    print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {message}")

# Background thread to sync logs from device
def auto_sync_logs():
    log_message("Starting ADB sync thread...")
    while True:
        try:
            # List files on device
            result = subprocess.run(
                ["adb", "shell", "ls", DEVICE_PATH],
                capture_output=True, text=True
            )
            
            if result.returncode == 0:
                device_files = [f for f in result.stdout.strip().split("\n") if f.endswith(".json")]
                log_message(f"Found {len(device_files)} log files on device")
                
                for device_file in device_files:
                    dest_file = os.path.join(LOG_DIR, device_file)
                    if not os.path.exists(dest_file):
                        log_message(f"New file detected: {device_file} - attempting pull...")
                        pull_result = subprocess.run([
                            "adb", "pull",
                            f"{DEVICE_PATH}/{device_file}",
                            dest_file
                        ], capture_output=True, text=True)
                        
                        if pull_result.returncode == 0:
                            log_message(f"Successfully pulled {device_file}")
                        else:
                            log_message(f"Failed to pull {device_file}: {pull_result.stderr}")
            else:
                log_message(f"ADB ls command failed: {result.stderr}")
                
        except Exception as e:
            log_message(f"Error during ADB sync: {str(e)}")

        time.sleep(5)  # Check every 5 seconds

# Flask Routes
@app.route('/')
def index():
    return render_template('index.html')

@app.route('/logs')
def list_logs():
    logs = []
    try:
        # Sort by modification time (newest first)
        log_files = sorted(
            [f for f in os.listdir(LOG_DIR) if f.endswith(".json")],
            key=lambda x: os.path.getmtime(os.path.join(LOG_DIR, x)),
            reverse=True
        )
        
        for fname in log_files:
            file_path = os.path.join(LOG_DIR, fname)
            try:
                with open(file_path) as f:
                    file_content = json.load(f)
                    logs.append({
                        "filename": fname,
                        "content": file_content,
                        "mtime": os.path.getmtime(file_path)
                    })
                    log_message(f"Successfully loaded log file: {fname}")
            except json.JSONDecodeError as je:
                logs.append({
                    "filename": fname,
                    "content": {"error": "Invalid JSON"},
                    "mtime": os.path.getmtime(file_path)
                })
                log_message(f"JSON decode error in {fname}: {str(je)}")
            except Exception as e:
                logs.append({
                    "filename": fname,
                    "content": {"error": str(e)},
                    "mtime": os.path.getmtime(file_path)
                })
                log_message(f"Error processing {fname}: {str(e)}")
                
    except Exception as e:
        log_message(f"Error listing logs: {str(e)}")
        return jsonify({"error": str(e)}), 500
        
    return jsonify(logs)

# Run the app and the background sync
if __name__ == '__main__':
    log_message("Starting PhishSafe Analytics Server")
    sync_thread = threading.Thread(target=auto_sync_logs, daemon=True)
    sync_thread.start()
    log_message(f"Sync thread started: {sync_thread.is_alive()}")
    
    app.run(debug=True, port=5001)