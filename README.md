# Project Overview

## Ghost Vision

Ghost Vision is an advanced image processing application that leverages deep learning models to detect and classify atmospheric phenomena.

### Architecture

The architecture consists of the following layers:

- **Data Ingestion**: Collects and preprocesses images from various sources.
- **Model Training**: Utilizes TensorFlow/Keras for training neural networks.
- **Inference Service**: A REST API built with Flask to serve predictions.
- **Frontend Dashboard**: A web interface for users to interact with the application and visualize results.

### Requirements

- Python >= 3.8
- Flask >= 2.0
- TensorFlow >= 2.4
- NumPy >= 1.19
- OpenCV >= 4.5

### Dependencies

Install the required Python packages using pip:

```bash
pip install -r requirements.txt
```

### Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/Cat404x/ghost_vision.git
   cd ghost_vision
   ```
2. Install the dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Run the Flask application:
   ```bash
   python app.py
   ```
4. Access the dashboard at `http://localhost:5000`.

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Acknowledgements

- TensorFlow Team
- Flask Documentation

---