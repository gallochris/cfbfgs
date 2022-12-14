FROM analythium/r2u-quarto:20.04

RUN install.r \
    reactable \
    dplyr \ 
    scales \
    stringr \
    tidyverse

RUN addgroup --system app && adduser --system --ingroup app app
WORKDIR /home/app
COPY shiny .
RUN quarto render index.qmd
RUN chown app:app -R /home/app
USER app

EXPOSE 8080

CMD ["quarto", "serve", "index.qmd", "--port", "8080", "--host", "0.0.0.0", "--no-render"]
