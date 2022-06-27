from distutils.log import debug
from email.policy import default
import os
from unicodedata import name
from flask import Flask, render_template, flash, request, redirect, url_for
import pytest
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

UPLOAD_FOLDER = './uploads'
ALLOWED_EXTENSIONS = {'py'}

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///score_board'
db = SQLAlchemy(app)


class board(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(200), nullable=False)
    date_created = db.Column(db.DateTime, default=datetime.utcnow)

    def __repr__(self):
        return '<Submission %>' % self.id

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':

        try:
            board_name = request.form['name']
            new_record = board(name=board_name)

            try:
                db.session.add(new_record)
                db.session.commit()
                return redirect('/')
            except:
                print("DB add issue")

        except:
            print("Not a record submission")    

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
            #retcode = pytest.main()
            #retcode = pytest.main(['--cache-clear', '-d --tx popen//python=python3.8',  'uploads/test_assignment1.py'])
            result = os.popen('py.test --cache-clear uploads/test_assignment1.py').read()
        except:
            render_template('wrong.html') 
        if result.find('passed') == -1:
            return render_template('wrong.html')
        else:
            return render_template('correct.html')
    records = board.query.order_by(board.date_created).all()
    return render_template('index.html', records=records)

if __name__ == "__main__":
    app.run(host='0.0.0.0')