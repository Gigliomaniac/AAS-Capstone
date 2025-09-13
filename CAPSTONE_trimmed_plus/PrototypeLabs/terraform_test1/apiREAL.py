# from flask import Flask, jsonify
# import subprocess
# import os

# app = Flask(__name__)

# # Make sure when calling to use create-lab and NOT create_lab
# @app.route('/create-lab', methods=['POST'])
# def create_lab():
#     try:
#         # Make sure we're in the in the right directory and returns if success and fail
#         subprocess.run(['terraform', 'init'], check=True, cwd=r'C:\Users\unddoma\CapstoneFolderTest\terraform_test1\firstsetup')
#         subprocess.run(['terraform', 'apply', '--auto-approve'], check=True, cwd=r'C:\Users\unddoma\CapstoneFolderTest\terraform_test1\firstsetup')
#         return jsonify({'status': 'Lab creation initiated'}), 200
#     except subprocess.CalledProcessError as e:
#         return jsonify({'status': 'Error occurred', 'message': str(e)}), 500

# # Debug shenans - loggin
# if __name__ == '__main__':
#     app.run(debug=True)


# how to run 
# python apiREAL.py in a python terminal and make sure we're in the right dir
# open new terminal with bash
# curl -X POST http://127.0.0.1:5000/create-lab
    # the address is just local host - probably the same once this is shifted over to another VM? We'll see

from flask import Flask, jsonify
import subprocess
import os
import threading
import time
from datetime import datetime

app = Flask(__name__)
TERRAFORM_DIR = os.path.join(os.path.dirname(__file__), 'firstsetup')
LOG_FILE = os.path.join(TERRAFORM_DIR, 'lab_activity.log')

def log_event(message):
    with open(LOG_FILE, 'a') as log:
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        log.write(f"[{timestamp}] {message}\n")

def destroy_after_delay(state_key, delay_seconds=300):
    time.sleep(delay_seconds)
    try:
        subprocess.run([
            'terraform', 'init', '-reconfigure',
            f'-backend-config=key=labs/{state_key}/terraform.tfstate'
        ], check=True, cwd=TERRAFORM_DIR)
        subprocess.run(['terraform', 'destroy', '--auto-approve'], check=True, cwd=TERRAFORM_DIR)
        log_event(f"Terraform destroy completed for state_key {state_key}.")
    except subprocess.CalledProcessError as e:
        log_event(f"Terraform destroy failed for {state_key}: {e}")

@app.route('/create-lab', methods=['POST'])
def create_lab():
    try:
        state_key = os.urandom(8).hex()

        subprocess.run([
            'terraform', 'init', '-reconfigure',
            f'-backend-config=key=labs/{state_key}/terraform.tfstate'
        ], check=True, cwd=TERRAFORM_DIR)
        subprocess.run(['terraform', 'apply', '--auto-approve'], check=True, cwd=TERRAFORM_DIR)
        log_event(f"Terraform apply executed successfully for state_key {state_key}.")
        threading.Thread(target=destroy_after_delay, args=(state_key,), daemon=True).start()
        return jsonify({'status': 'Lab creation initiated', 'state_key': state_key}), 200
    except subprocess.CalledProcessError as e:
        log_event(f"Terraform apply failed: {e}")
        return jsonify({'status': 'Error occurred', 'message': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
