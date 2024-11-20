package com.api.concurso.controller;

import org.python.util.PythonInterpreter;
import org.springframework.core.io.FileSystemResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;

@RestController
@RequestMapping("/api")
public class ConcursoController {
    @GetMapping
    public String helloWorld(){
        return "Hello World!";
    }

    @GetMapping("/csv")
    public ResponseEntity<FileSystemResource> generateCsv() {
        // Caminho para os scripts Python
        String basePath = new File("").getAbsolutePath();
        String scriptPath = basePath + "/src/main/resources/py/PCI.py";
        String outputCsvPath = basePath + "./ConcursosAtivos.csv";

        try {
            // Executa o script de geração de CSV (que agora também cuida da instalação das dependências)
            ProcessBuilder processBuilder = new ProcessBuilder("python", scriptPath);
            processBuilder.redirectErrorStream(true);
            Process process = processBuilder.start();

            // Captura a saída do processo de execução do script
            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(process.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    System.out.println("Geração de CSV: " + line);
                }
            }

            // Aguarda a execução do script de geração de CSV
            int exitCode = process.waitFor();
            if (exitCode != 0) {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                        .body(null);
            }

            // Verifica se o arquivo foi gerado
            File outputFile = new File(outputCsvPath);
            if (!outputFile.exists()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
            }

            // Retorna o arquivo como resposta
            FileSystemResource resource = new FileSystemResource(outputFile);
            HttpHeaders headers = new HttpHeaders();
            headers.add(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + outputFile.getName());
            headers.add(HttpHeaders.CONTENT_TYPE, "text/csv");

            return ResponseEntity.ok()
                    .headers(headers)
                    .body(resource);

        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(null);
        }
    }


}
