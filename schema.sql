#hi

DROP SCHEMA if exists `pulse_uni_schema`;
CREATE SCHEMA `pulse_uni_schema`;
USE pulse_uni_schema;

DROP TABLE IF EXISTS location;
CREATE TABLE location (
    location_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    address VARCHAR(100) NOT NULL,
    latitude FLOAT(5,3) NOT NULL CHECK(latitude BETWEEN -90.000 AND 90.000),
    longitude FLOAT(6,3) NOT NULL CHECK(longitude BETWEEN -180.000 AND 180.000),
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    continent VARCHAR(50) NOT NULL,
    CONSTRAINT unique_loc UNIQUE(latitude,longitude), #different location per year#
    PRIMARY KEY (location_id)
);

DROP TABLE IF EXISTS festival;
CREATE TABLE festival (
    festival_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    location_id INT UNSIGNED NOT NULL UNIQUE,           #different location per year#
    festival_name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    year INT GENERATED ALWAYS AS (YEAR(start_date)) STORED UNIQUE,
    PRIMARY KEY (festival_id),
    KEY idx_festival_name(festival_name),
    KEY idx_fk_location_id(location_id),
    CONSTRAINT fk_festival_location FOREIGN KEY (location_id) 
        REFERENCES location(location_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_festival_dates CHECK (end_date >= start_date)
);

DROP TABLE IF EXISTS stage;
CREATE TABLE stage (
    stage_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    stage_name VARCHAR(100) NOT NULL,
    description VARCHAR(1000),
    max_capacity INT UNSIGNED CHECK(max_capacity>0),
    PRIMARY KEY (stage_id),
    KEY idx_stage_name(stage_name)
);

DROP TABLE IF EXISTS event;
CREATE TABLE event (
    event_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    festival_id INT UNSIGNED NOT NULL,
    stage_id INT UNSIGNED NOT NULL,
    event_name VARCHAR(200) NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    duration INT GENERATED ALWAYS AS (TIMESTAMPDIFF(MINUTE, start_time, end_time)) STORED,
    PRIMARY KEY (event_id),
    KEY idx_fk_festival_id(festival_id),
    KEY idx_fk_stage_id(stage_id),
    KEY idx_event_name(event_name),
    CONSTRAINT valid_duration_event CHECK (duration BETWEEN 0 AND 720),
    CONSTRAINT fk_event_festival FOREIGN KEY (festival_id) 
        REFERENCES festival(festival_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_event_stage FOREIGN KEY (stage_id) 
        REFERENCES stage(stage_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

DROP TABLE IF EXISTS staff;
CREATE TABLE staff (
    staff_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    staff_name VARCHAR(50) NOT NULL,
    age INT UNSIGNED NOT NULL CHECK (age>0),
    role VARCHAR(50) NOT NULL,
    experience_level VARCHAR(100) NOT NULL CHECK(experience_level IN ('specialist','Beginner', 'Intermediate','Experienced', 'Very Experienced')),
    job VARCHAR(100) NOT NULL CHECK(job IN ('technical', 'security', 'assistant')),
    PRIMARY KEY (staff_id),
    KEY idx_staff_name(staff_name)
);

-- Technical Staff table (Τεχνικό)
DROP TABLE IF EXISTS technical_staff;
CREATE TABLE technical_staff (
    staff_id INT UNSIGNED NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    PRIMARY KEY (staff_id),
    KEY idx_fk_staff_id(staff_id),
    CONSTRAINT fk_technical_staff_staff FOREIGN KEY (staff_id) 
        REFERENCES staff(staff_id) ON DELETE RESTRICT ON UPDATE CASCADE
);


DROP TABLE IF EXISTS staff_event;
CREATE TABLE staff_event (
    staff_id INT UNSIGNED NOT NULL,
    event_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (staff_id, event_id),
    KEY idx_fk_staff_id(staff_id),
    KEY idx_fk_event_id(event_id),
    CONSTRAINT fk_staff_event_staff FOREIGN KEY (staff_id)
        REFERENCES staff(staff_id) ON DELETE RESTRICT ON UPDATE CASCADE,       
    CONSTRAINT fk_staff_event_event FOREIGN KEY (event_id)
        REFERENCES event(event_id) ON DELETE RESTRICT ON UPDATE CASCADE       
);

DROP TABLE IF EXISTS equipment;
CREATE TABLE equipment (
    equipment_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    type VARCHAR(100) NOT NULL,
    PRIMARY KEY (equipment_id)
);

DROP TABLE IF EXISTS stage_equipment;
CREATE TABLE stage_equipment (
    equipment_id INT UNSIGNED NOT NULL,
    stage_id INT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL DEFAULT 0 CHECK(quantity>=0),
    PRIMARY KEY (equipment_id, stage_id),
    KEY idx_fk_equipment_id(equipment_id),
    KEY idx_fk_stage_id(stage_id),
    CONSTRAINT fk_stage_equipment_equipment FOREIGN KEY (equipment_id) 
        REFERENCES equipment(equipment_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_stage_equipment_stage FOREIGN KEY (stage_id) 
        REFERENCES stage(stage_id) ON DELETE RESTRICT ON UPDATE CASCADE        
);

DROP TABLE IF EXISTS artist;
CREATE TABLE artist (
    artist_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    artist_name VARCHAR(100) NOT NULL,
    pseudonym VARCHAR(50),
    birth_date DATE NOT NULL,  #there is a trgger#
    #age INT GENERATED ALWAYS AS (TIMESTAMPDIFF(YEAR, birth_date, YEAR(NOW()))) STORED, CHECK(age>0),#
    website VARCHAR(200) CHECK (website LIKE 'https://%'),
    instagram VARCHAR(200),
    PRIMARY KEY (artist_id),
    INDEX idx_artist_name(artist_name)
);

DROP TABLE IF EXISTS performance;
CREATE TABLE performance (
    performance_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    event_id INT UNSIGNED NOT NULL,
    type_of_performance VARCHAR(50) NOT NULL CHECK(type_of_performance IN ('warm up', 'headline', 'Special guest', 'other')),
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    duration INT GENERATED ALWAYS AS (TIMESTAMPDIFF(MINUTE, start_time, end_time)) STORED,
    PRIMARY KEY (performance_id),
    KEY idx_fk_event_id(event_id),
    CONSTRAINT max_duration_performance CHECK (duration <= 180),
    CONSTRAINT fk_performance_event FOREIGN KEY (event_id) 
        REFERENCES event(event_id) ON DELETE RESTRICT ON UPDATE CASCADE
); 

DROP TABLE IF EXISTS performance_artist;
CREATE TABLE performance_artist (
    performance_id INT UNSIGNED NOT NULL,
    artist_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (performance_id, artist_id),
    KEY idx_fk_performance_id(performance_id),
    KEY idx_fk_artist_id(artist_id),
    CONSTRAINT fk_performance_artist_performance FOREIGN KEY (performance_id) 
        REFERENCES performance(performance_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_performance_artist_artist FOREIGN KEY (artist_id) 
        REFERENCES artist(artist_id) ON DELETE RESTRICT ON UPDATE CASCADE
);


DROP TABLE IF EXISTS artist_genre;
CREATE TABLE artist_genre (
    artist_id INT UNSIGNED NOT NULL,
    genre VARCHAR(50) NOT NULL,
    subgenre VARCHAR(50) NOT NULL,
    PRIMARY KEY (artist_id, genre, subgenre),
    KEY idx_fk_artist_id(artist_id),
    CONSTRAINT fk_artist_genre_artist FOREIGN KEY (artist_id) 
        REFERENCES artist(artist_id) ON DELETE RESTRICT ON UPDATE CASCADE  
);

DROP TABLE IF EXISTS band;
CREATE TABLE band (
    band_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    band_name VARCHAR(100) NOT NULL,
    formation_date DATE NOT NULL,
    website VARCHAR(200),
    instagram VARCHAR(200),
    PRIMARY KEY (band_id)
);

DROP TABLE IF EXISTS band_genre;
CREATE TABLE band_genre (
    band_id INT UNSIGNED NOT NULL,
    genre VARCHAR(100) NOT NULL,
    subgenre VARCHAR(100) NOT NULL,
    PRIMARY KEY (band_id, genre, subgenre),
    KEY idx_fk_band_id(band_id),
    CONSTRAINT fk_band_genre_band FOREIGN KEY (band_id) 
        REFERENCES band(band_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

DROP TABLE IF EXISTS band_member;
CREATE TABLE band_member (
    artist_id INT UNSIGNED NOT NULL,
    band_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (artist_id, band_id),
    KEY idx_fk_artist_id(artist_id),
    KEY idx_fk_band_id(band_id),
    CONSTRAINT fk_band_member_artist FOREIGN KEY (artist_id) 
        REFERENCES artist(artist_id) ON DELETE RESTRICT ON UPDATE CASCADE,    
    CONSTRAINT fk_band_member_band FOREIGN KEY (band_id) 
        REFERENCES band(band_id) ON DELETE RESTRICT ON UPDATE CASCADE 
);


DROP TABLE IF EXISTS visitor;
CREATE TABLE visitor (
    visitor_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    visitor_name VARCHAR(100) NOT NULL,
    age INT UNSIGNED CHECK(age>0),
    PRIMARY KEY (visitor_id),
    KEY idx_visitor_name(visitor_name)
);


DROP TABLE IF EXISTS ticket;
CREATE TABLE ticket (
    ticket_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    EAN13 CHAR(13) NOT NULL UNIQUE,
    event_id INT UNSIGNED NOT NULL,
    visitor_id INT UNSIGNED NOT NULL,
    purchase_time DATETIME,    
    cost FLOAT NOT NULL CHECK(cost>=0),
    purchase_method VARCHAR(300) CHECK (purchase_method IS NULL OR purchase_method IN ('credit_card', 'debit_card', 'bank_account', 'non_cash', 'cash')),      
    category VARCHAR(300) NOT NULL CHECK (category IN ('general_admission', 'vip', 'backstage', 'other')),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (ticket_id),
    KEY idx_fk_event_id(event_id),
    KEY idx_fk_visitor_id(visitor_id),
    CONSTRAINT unique_ticket_per_visitor UNIQUE (event_id,visitor_id),           #one ticket for the same event per visitor#
    CONSTRAINT fk_ticket_event FOREIGN KEY (event_id) 
        REFERENCES event(event_id) ON DELETE RESTRICT ON UPDATE CASCADE,  
    CONSTRAINT fk_ticket_visitor FOREIGN KEY (visitor_id) 
        REFERENCES visitor(visitor_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Visitor Contact table (Επισκέπτης_Επικοινωνία)
DROP TABLE IF EXISTS visitor_contact;
CREATE TABLE visitor_contact (
    contact_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    visitor_id INT UNSIGNED NOT NULL,
    phone VARCHAR(15),
    email VARCHAR(250),
    PRIMARY KEY (contact_id),
    KEY idx_fk_visitor_id(visitor_id),
    CONSTRAINT unique_phone_email UNIQUE(phone,email),
    CONSTRAINT fk_visitor_contact_visitor FOREIGN KEY (visitor_id) 
        REFERENCES visitor(visitor_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

DROP TABLE IF EXISTS resale_queue;
CREATE TABLE resale_queue (
    resale_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT UNSIGNED NOT NULL,
    visitor_id INT UNSIGNED NOT NULL,
    request_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_completed BOOLEAN DEFAULT FALSE,
    KEY idx_fk_resale_queue_ticket_id(ticket_id),
    KEY idx_fk_resale_queue_visitor_id(visitor_id),
    CONSTRAINT fk_resale_queue_ticket FOREIGN KEY (ticket_id) 
        REFERENCES ticket(ticket_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_resale_queue_visitor FOREIGN KEY (visitor_id) 
        REFERENCES visitor(visitor_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

DROP TABLE IF EXISTS buyer_interest_queue;
CREATE TABLE buyer_interest_queue (
    buyer_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    buyer_name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    visitor_id INT UNSIGNED NULL,
    ticket_id INT UNSIGNED  NULL, 
    event_id INT UNSIGNED NULL,   
    category VARCHAR(100) CHECK (category IS NULL OR category IN ('general_admission', 'vip', 'backstage', 'other')),
    request_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_fulfilled BOOLEAN DEFAULT FALSE,
    KEY idx_fk_buyer_interest_queue_visitor_id(visitor_id),
    KEY idx_fk_buyer_interest_queue_ticket_id(ticket_id),
    KEY idx_fk_buyer_interest_queue_event_id(event_id),
    CONSTRAINT fk_buyer_interest_queue_visitor FOREIGN KEY (visitor_id) 
        REFERENCES visitor(visitor_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_buyer_interest_queue_ticket FOREIGN KEY (ticket_id) 
        REFERENCES ticket(ticket_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_buyer_interest_queue_event FOREIGN KEY (event_id) 
        REFERENCES event(event_id) ON DELETE RESTRICT ON UPDATE CASCADE
    #CONSTRAINT chk_lack_interest CHECK(ticket_id IS NOT NULL OR (event_id IS NOT NULL AND category IS NOT NULL))#
);


DROP TABLE IF EXISTS review;
CREATE TABLE review (
    review_id INT UNSIGNED AUTO_INCREMENT,
    visitor_id INT UNSIGNED NOT NULL,
    performance_id INT UNSIGNED NOT NULL,
    artist_performance TINYINT UNSIGNED NOT NULL CHECK (artist_performance BETWEEN 1 AND 5),       
    sound_lighting TINYINT UNSIGNED NOT NULL CHECK (sound_lighting BETWEEN 1 AND 5),  
    stage_presence TINYINT UNSIGNED NOT NULL CHECK (stage_presence BETWEEN 1 AND 5),   
    organization TINYINT UNSIGNED NOT NULL CHECK (organization BETWEEN 1 AND 5),   
    overall_impression TINYINT UNSIGNED NOT NULL CHECK (overall_impression BETWEEN 1 AND 5),
    PRIMARY KEY (review_id),
    KEY idx_fk_visitor_id(visitor_id),
    KEY idx_fk_performance_id(performance_id),
    CONSTRAINT fk_review_visitor FOREIGN KEY (visitor_id) 
        REFERENCES visitor(visitor_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_review_performance FOREIGN KEY (performance_id)
        REFERENCES performance(performance_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
