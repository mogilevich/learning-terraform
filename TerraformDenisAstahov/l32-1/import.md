import { #my web sg
    id = sg-111
    to = aws_security_group.web
}

import { #my web ec2
    id = ec2-1111
    to = aws_ec2_instace.web
}


# cli
# terrfarom init
# terrafrom plan -generate-config-out=generated-sg.tf
# terrfarom apply
 