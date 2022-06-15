from distutils.log import debug
import os
from flask import Flask, render_template, flash, request, redirect, url_for
import pytest

UPLOAD_FOLDER = './uploads'
ALLOWED_EXTENSIONS = {'py'}

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        # check if the post request has the file part
        if 'file' not in request.files:
            flash('No file part')
            return redirect(request.url)
        file = request.files['file']
        # If the user does not select a file, the browser submits an
        # empty file without a filename.
        if file.filename == '':
            flash('No selected file')
            return redirect(request.url)
        file.save("./uploads/assignment.py")
        #result = int(os.popen('python3 ./uploads/assignment.py 1 2').read())
        try:
            retcode = pytest.main()
        except:
            render_template('wrong.html') 
        if retcode == 0:
            return render_template('correct.html')
        else:
            return render_template('wrong.html')
    return render_template('index.html')

if __name__ == "__main__":
    app.run(debug=True)