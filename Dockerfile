FROM node:14

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# Expose the port the app runs on
EXPOSE 80

ENTRYPOINT ["npm"]
# Define the command to run the app
CMD ["start"]
