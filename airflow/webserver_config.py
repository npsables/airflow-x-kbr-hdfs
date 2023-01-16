## ldap here
import os

# from flask_appbuilder.security.manager import AUTH_DB

from flask_appbuilder.security.manager import AUTH_LDAP


AUTH_TYPE = AUTH_LDAP
AUTH_LDAP_SERVER = "ldap://ldap.forumsys.com:389"
AUTH_LDAP_USE_TLS = False


# All user passwords are password.
# riemann
# gauss
# euler
# euclid
# ou=scientists,dc=example,dc=com
# einstein
# newton
# galieleo
# tesla


AUTH_LDAP_SEARCH = "dc=example,dc=com"  # the LDAP search base
AUTH_LDAP_UID_FIELD = "uid"  # the username field

# For a typical OpenLDAP setup (where LDAP searches require a special account):
# The user must be the LDAP USER as defined in LDAP_ADMIN_USERNAME
AUTH_LDAP_BIND_USER = "cn=read-only-admin,dc=example,dc=com"  # the special bind username for search
AUTH_LDAP_BIND_PASSWORD = "password"  # the special bind password for search


# registration configs
AUTH_USER_REGISTRATION = True  # allow users who are not already in the FAB DB
AUTH_USER_REGISTRATION_ROLE = "User"  # this role will be given in addition to any AUTH_ROLES_MAPPING
AUTH_LDAP_FIRSTNAME_FIELD = "givenName"
AUTH_LDAP_LASTNAME_FIELD = "sn"
AUTH_LDAP_EMAIL_FIELD = "mail"  # if null in LDAP, email is set to: "{username}@email.notfound"


# a mapping from LDAP DN to a list of FAB roles
AUTH_ROLES_MAPPING = {
    "cn=Marketing,ou=scientists,dc=example,dc=com": ["User"],
    "cn=Data_science,ou=mathematicians,dc=example,dc=com": ["User"],
    "cn=Admin,ou=Groups,dc=example,dc=com": ["Admin"],
}

# the LDAP user attribute which has their role DNs
AUTH_LDAP_GROUP_FIELD = "memberOf"

# if we should replace ALL the user's roles each login, or only on registration
AUTH_ROLES_SYNC_AT_LOGIN = True

# force users to re-auth after 30min of inactivity (to keep roles in sync)
PERMANENT_SESSION_LIFETIME = 1800
