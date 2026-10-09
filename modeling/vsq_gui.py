import tkinter as tk
import numpy as np
from tkinter import ttk, messagebox
from joblib import load
from pathlib import Path
# -------------------------------------------------------------
#  Replace `predict_value` with **your own** model/function call.
#  It must accept two numeric inputs (BVD, VET) and return a
#  single numeric prediction.
# ----------------------------------------------------------

# MODEL_PATH = Path(__file__).with_name("classification.joblib")  
MODEL_PATH = Path(__file__).resolve().parents[1] / 'artifacts' / 'classification.joblib'
if not MODEL_PATH.exists():
    raise FileNotFoundError(f"doesn't exist{MODEL_PATH.resolve()}")
_model = load(MODEL_PATH)

def predict_value(bvd: float, vet: float, age: int):
    """Stub — replace with your trained model call.

    Example:
        return my_model.predict([[bvd, vet]])[0]
    """
    # --- demo placeholder (delete when you plug in your model) ---
    X_input = np.array([[vet, bvd, age]], dtype=float)
    # 如果保存的是 Pipeline，前处理会自动执行
    pred = _model.predict(X_input)
    return str(pred[0])


# ---------------------- Tkinter GUI ---------------------------

def main():

    root = tk.Tk()
    root.title("VSQ Predictor (BVD + VET + AGE)")
    root.geometry("320x300")
    root.resizable(False, False)

    # Configure a simple themed style
    style = ttk.Style()
    style.theme_use("clam")

    mainframe = ttk.Frame(root, padding="20 15 20 15")
    mainframe.grid(row=0, column=0, sticky="NSEW")

    # Make the grid expand nicely if window is resized
    root.columnconfigure(0, weight=1)
    root.rowconfigure(0, weight=1)

    # Tk variables
    bvd_var = tk.StringVar()
    vet_var = tk.StringVar()
    age_var = tk.StringVar()
    result_var = tk.StringVar()

    # ---- Row 0 : BVD input ----
    ttk.Label(mainframe, text="BVD:").grid(row=0, column=0, sticky="E", padx=5, pady=5)
    bvd_entry = ttk.Entry(mainframe, textvariable=bvd_var, width=15)
    bvd_entry.grid(row=0, column=1, padx=5, pady=5)

    # ---- Row 1 : VET input ----
    ttk.Label(mainframe, text="VET:").grid(row=1, column=0, sticky="E", padx=5, pady=5)
    vet_entry = ttk.Entry(mainframe, textvariable=vet_var, width=15)
    vet_entry.grid(row=1, column=1, padx=5, pady=5)
    # ---- Row2 : AGE input
    ttk.Label(mainframe, text="AGE:").grid(row=2, column=0, sticky="E", padx=5, pady=5)
    age_entry = ttk.Entry(mainframe, textvariable=age_var, width=15)
    age_entry.grid(row=2, column=1, padx=5, pady=5)
    # ---- Row 2 : Predict button ----
    def on_predict():
        """Callback run when the Predict button is clicked."""
        try:
            bvd_val = float(bvd_var.get())
            vet_val = float(vet_var.get())
            age_val = int(age_var.get())
        except ValueError:
            messagebox.showwarning("Input Error", "Please enter valid numeric values for BVD VET and AGE.")
            return

        pred = predict_value(bvd_val, vet_val, age_val)
        result_var.set(pred)

    ttk.Button(mainframe, text="Predict", command=on_predict).grid(row=3, column=0, columnspan=2, pady=12)

    # ---- Row 3 : Result display ----
    ttk.Label(mainframe, text="Predicted Value:").grid(row=4, column=0, sticky="E", padx=5, pady=5)
    ttk.Label(mainframe, textvariable=result_var, width=15, foreground="blue").grid(row=4, column=1, padx=5, pady=5)

    # Focus on first entry by default
    bvd_entry.focus()

    root.mainloop()


if __name__ == "__main__":
    main()
