from flask import Flask, render_template, request, redirect, url_for, flash
import sqlite3

app = Flask(__name__)
app.secret_key = "microscope_calculator_secret_key"

# Database setup
def get_db_connection():
    conn = sqlite3.connect('specimens.db')
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    with get_db_connection() as conn:
        conn.execute("CREATE TABLE IF NOT EXISTS specimens (username TEXT, specimen_size REAL, actual_size REAL)")

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/calculate', methods=['POST'])
def calculate():
    try:
        username = request.form['username']
        microscope_size = float(request.form['microscope_size'])
        magnification = float(request.form['magnification'])
        
        actual_size = microscope_size / magnification
        
        with get_db_connection() as conn:
            conn.execute("INSERT INTO specimens VALUES (?, ?, ?)", 
                        (username, microscope_size, actual_size))
            
        flash(f'Calculation successful! Actual size: {actual_size:.2f} um')
        return redirect(url_for('index'))
    
    except ValueError:
        flash('Please enter valid numerical values for microscope size and magnification')
        return redirect(url_for('index'))
    except Exception as e:
        flash(f'An error occurred: {str(e)}')
        return redirect(url_for('index'))

@app.route('/records')
def records():
    with get_db_connection() as conn:
        specimens = conn.execute("SELECT * FROM specimens").fetchall()
    return render_template('records.html', specimens=specimens)

init_db()
if __name__ == '__main__':
    
    app.run(debug=True)
