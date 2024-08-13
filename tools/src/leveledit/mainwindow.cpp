#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QFileDialog>
#include <QFile>
#include <QTextStream>
#include <QGraphicsRectItem>
#include <QPen>
#include <QBrush>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    // Initialize text editor and preview view
    textEdit = new QTextEdit(this);
    previewView = new QGraphicsView(this);
    scene = new QGraphicsScene(this);

    ui->centralwidget->setLayout(new QVBoxLayout);
    ui->centralwidget->layout()->addWidget(textEdit);
    ui->centralwidget->layout()->addWidget(previewView);

    previewView->setScene(scene);

    connect(textEdit, &QTextEdit::textChanged, this, &MainWindow::on_textEdit_textChanged);
    connect(ui->actionOpen, &QAction::triggered, this, &MainWindow::on_actionOpen_triggered);
    connect(ui->actionSave, &QAction::triggered, this, &MainWindow::on_actionSave_triggered);
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::on_textEdit_textChanged()
{
    updatePreview();
}

void MainWindow::on_actionOpen_triggered()
{
    QString fileName = QFileDialog::getOpenFileName(this, tr("Open Level File"), "", tr("Level Files (*.ini);;All Files (*)"));
    if (!fileName.isEmpty()) {
        QFile file(fileName);
        if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QTextStream in(&file);
            textEdit->setPlainText(in.readAll());
            file.close();
            updatePreview();
        }
    }
}

void MainWindow::on_actionSave_triggered()
{
    QString fileName = QFileDialog::getSaveFileName(this, tr("Save Level File"), "", tr("Level Files (*.ini);;All Files (*)"));
    if (!fileName.isEmpty()) {
        QFile file(fileName);
        if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            QTextStream out(&file);
            out << textEdit->toPlainText();
            file.close();
        }
    }
}

void MainWindow::updatePreview()
{
    scene->clear();
    QString text = textEdit->toPlainText();
    QStringList lines = text.split('\n');
    int tileSize = 40;
    for (int y = 0; y < lines.size(); ++y) {
        QString line = lines[y];
        for (int x = 0; x < line.length(); ++x) {
            QChar ch = line[x];
            if (ch == '1' || ch == 'G') {
                QGraphicsRectItem *rect = scene->addRect(x * tileSize, y * tileSize, tileSize, tileSize, QPen(Qt::black), QBrush(ch == '1' ? Qt::gray : Qt::blue));
                rect->setPos(x * tileSize, y * tileSize);
            }
        }
    }
    previewView->setSceneRect(scene->itemsBoundingRect());
}
