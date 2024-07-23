Add a job entry if you have a specific job for garbage collection

qb-core/shared/jobs.lua

below is the code you will put into the jobs.lua


['garbage'] = {
    label = 'Garbage Collector',
    defaultDuty = true,
    grades = {
        ['0'] = {
            name = 'Trainee',
            payment = 50
        },
        ['1'] = {
            name = 'Collector',
            payment = 75
        },
        ['2'] = {
            name = 'Senior Collector',
            payment = 100
        }
    }
}
