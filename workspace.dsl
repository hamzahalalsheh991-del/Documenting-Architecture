workspace "Fitness Tracker" "Документирование архитектуры фитнес-трекера (Вариант 14)" {
    model {
        users = person "Пользователь" "Человек, использующий приложение для учёта тренировок"

        fitnessTracker = softwareSystem "FitnessTracker" "Система для ведения тренировок и упражнений" {
            tags "System"
        }

        users -> fitnessTracker "Использует"

        // Контейнеры
        spa = container "Single Page App" "React" "Веб-интерфейс для пользователей"
        gateway = container "API Gateway" "Node.js + Express" "Единая точка входа, маршрутизация запросов"
        userService = container "User Service" "Java Spring Boot" "Управление пользователями"
        exerciseService = container "Exercise Service" "Java Spring Boot" "Управление упражнениями"
        workoutService = container "Workout Service" "Java Spring Boot" "Управление тренировками и статистикой"
        userDb = container "User DB" "PostgreSQL" "Хранение данных пользователей"
        exerciseDb = container "Exercise DB" "PostgreSQL" "Хранение данных упражнений"
        workoutDb = container "Workout DB" "PostgreSQL" "Хранение данных тренировок"

        // Связи
        users -> spa "Использует" "HTTPS"
        spa -> gateway "Отправляет API-запросы" "HTTPS/REST"
        gateway -> userService "Маршрутизирует запросы" "HTTPS/REST"
        gateway -> exerciseService "Маршрутизирует запросы" "HTTPS/REST"
        gateway -> workoutService "Маршрутизирует запросы" "HTTPS/REST"

        userService -> userDb "Читает/пишет" "JDBC"
        exerciseService -> exerciseDb "Читает/пишет" "JDBC"
        workoutService -> workoutDb "Читает/пишет" "JDBC"

        workoutService -> userService "Проверяет существование пользователя" "HTTPS/REST"
        workoutService -> exerciseService "Проверяет существование упражнений" "HTTPS/REST"
    }

    views {
        systemcontext fitnessTracker "SystemContext" "Контекстная диаграмма системы FitnessTracker" {
            include *
            autolayout lr
        }

        container fitnessTracker "Containers" "Диаграмма контейнеров системы FitnessTracker" {
            include *
            autolayout lr
        }

        dynamic fitnessTracker "CreateWorkout" "Динамическая диаграмма создания тренировки" {
            include spa gateway workoutService userService exerciseService workoutDb
            autoLayout

            # Сценарий создания тренировки
            spa -> gateway "POST /api/workouts"
            gateway -> workoutService "POST /workouts"
            workoutService -> exerciseService "GET /exercises/{id}" for each exercise
            exerciseService -> exerciseDb "SELECT"
            exerciseDb -> exerciseService "данные упражнения"
            exerciseService -> workoutService "ответ"
            workoutService -> userService "GET /users/{id}"
            userService -> userDb "SELECT"
            userDb -> userService "данные пользователя"
            userService -> workoutService "ответ"
            workoutService -> workoutDb "INSERT"
            workoutDb -> workoutService "подтверждение"
            workoutService -> gateway "201 Created"
            gateway -> spa "201 Created"
        }

        styles {
            element "Person" {
                shape person
                background #08427b
                color #ffffff
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
        }

        theme default
    }
}
