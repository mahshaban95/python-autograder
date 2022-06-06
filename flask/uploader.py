import os
from flask import Flask, flash, request, redirect, url_for
# from werkzeug.utils import secure_filename

UPLOAD_FOLDER = './uploads'
ALLOWED_EXTENSIONS = {'py'}

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/', methods=['GET', 'POST'])
def upload_file():
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
        #if file and allowed_file(file.filename):
        # filename = secure_filename(file.filename)
        #file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
        file.save("./uploads/cal.py")
        #return redirect(url_for('download_file', name=filename))
        result = int(os.popen('python3 ./uploads/cal.py 1 2').read())
        if result == 3:
            return "Correct!"
        else:
            return "Wrong, try again"
    return '''
    <!doctype html>
    <title>Upload Your Assignment</title>
    <h1>Upload Your Assignment</h1>
    <form method=post enctype=multipart/form-data>
      <input type=file name=file>
      <input type=submit value=Upload>
    </form>
    '''

if __name__ == "__main__":
    app.run()   