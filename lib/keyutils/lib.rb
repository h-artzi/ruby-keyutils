require 'ffi'

module Keyutils
  module Lib
    extend FFI::Library
    ffi_lib %w(keyutils keyutils.so.1)

    def self.attach_text_string name
      lib = ffi_libraries.first
      val = lib.find_variable(name.to_s).get_string 0
      singleton_class.send :define_method, name, ->() { val }
    end

    attach_text_string :keyutils_version_string
    attach_text_string :keyutils_build_string

    # key serial number
    typedef :int32_t, :key_serial_t

    # special process keyring shortcut IDs
    KEY_SPEC = {
      THREAD_KEYRING: -1, # key ID for thread-specific keyring
      PROCESS_KEYRING: -2, # key ID for process-specific keyring
      SESSION_KEYRING: -3, # key ID for session-specific keyring
      USER_KEYRING: -4, # key ID for UID-specific keyring
      USER_SESSION_KEYRING: -5, # key ID for UID-session keyring
      GROUP_KEYRING: -6, # key ID for GID-specific keyring
      REQKEY_AUTH_KEY: -7 # key ID for assumed request_key auth key
    }

    # request-key default keyrings
    KEY_REQKEY_DEFL = {
      NO_CHANGE: -1,
      DEFAULT: 0,
      THREAD_KEYRING: 1,
      PROCESS_KEYRING: 2,
      SESSION_KEYRING: 3,
      USER_KEYRING: 4,
      USER_SESSION_KEYRING: 5,
      GROUP_KEYRING: 6
    }

    # key handle permissions mask
    typedef :uint32, :key_perm_t;

    KEY_POS = {
      VIEW: 0x01000000, # possessor can view a key's attributes
      READ: 0x02000000, # possessor can read key payload / view keyring
      WRITE: 0x04000000, # possessor can update key payload / add link to keyring
      SEARCH: 0x08000000, # possessor can find a key in search / search a keyring
      LINK: 0x10000000, # possessor can create a link to a key/keyring
      SETATTR: 0x20000000, # possessor can set key attributes
      ALL: 0x3f000000
    }

    # user permissions...
    KEY_USR = {
      VIEW: 0x00010000,
      READ: 0x00020000,
      WRITE: 0x00040000,
      SEARCH: 0x00080000,
      LINK: 0x00100000,
      SETATTR: 0x00200000,
      ALL: 0x003f0000
    }

    # group permissions...
    KEY_GRP = {
      VIEW: 0x00000100,
      READ: 0x00000200,
      WRITE: 0x00000400,
      SEARCH: 0x00000800,
      LINK: 0x00001000,
      SETATTR: 0x00002000,
      ALL: 0x00003f00
    }

    # third party permissions...
    KEY_OTH = {
      VIEW: 0x00000001,
      READ: 0x00000002,
      WRITE: 0x00000004,
      SEARCH: 0x00000008,
      LINK: 0x00000010,
      SETATTR: 0x00000020,
      ALL: 0x0000003f
    }

    # keyctl commands
    KEYCTL = {
      GET_KEYRING_ID: 0, # ask for a keyring's ID
      JOIN_SESSION_KEYRING: 1, # join or start named session keyring
      UPDATE: 2, # update a key
      REVOKE: 3, # revoke a key
      CHOWN: 4, # set ownership of a key
      SETPERM: 5, # set perms on a key
      DESCRIBE: 6, # describe a key
      CLEAR: 7, # clear contents of a keyring
      LINK: 8, # link a key into a keyring
      UNLINK: 9, # unlink a key from a keyring
      SEARCH: 10, # search for a key in a keyring
      READ: 11, # read a key or keyring's contents
      INSTANTIATE: 12, # instantiate a partially constructed key
      NEGATE: 13, # negate a partially constructed key
      SET_REQKEY_KEYRING: 14, # set default request-key keyring
      SET_TIMEOUT: 15, # set timeout on a key
      ASSUME_AUTHORITY: 16, # assume authority to instantiate key
      GET_SECURITY: 17, # get key security label
      SESSION_TO_PARENT: 18, # set my session keyring on my parent process
      REJECT: 19, # reject a partially constructed key
      INSTANTIATE_IOV: 20, # instantiate a partially constructed key
      INVALIDATE: 21, # invalidate a key
      GET_PERSISTENT: 22 # get a user's persistent keyring
    }

    #
    # syscall wrappers
    #

    # extern key_serial_t add_key(const char *type,
    #       const char *description,
    #       const void *payload,
    #       size_t plen,
    #       key_serial_t ringid);
    attach_function :add_key, [:string, :string, :pointer, :size_t, :key_serial_t], :key_serial_t

    # extern key_serial_t request_key(const char *type,
    # 				const char *description,
    # 				const char *callout_info,
    # 				key_serial_t destringid);
    attach_function :request_key, [:string, :string, :string, :key_serial_t], :key_serial_t

    # extern long keyctl(int cmd, ...);
    attach_function :keyctl, [:int, :varargs], :long

    #
    # keyctl function wrappers
    #

    # extern key_serial_t keyctl_get_keyring_ID(key_serial_t id, int create);
    attach_function :keyctl_get_keyring_ID, [:key_serial_t, :bool], :key_serial_t

    # extern key_serial_t keyctl_join_session_keyring(const char *name);
    attach_function :keyctl_join_session_keyring, [:string], :key_serial_t

    # extern long keyctl_update(key_serial_t id, const void *payload, size_t plen);
    attach_function :keyctl_update, [:key_serial_t, :pointer, :size_t], :long

    # extern long keyctl_revoke(key_serial_t id);
    attach_function :keyctl_revoke, [:key_serial_t], :long

    # extern long keyctl_chown(key_serial_t id, uid_t uid, gid_t gid);
    attach_function :keyctl_chown, [:key_serial_t, :uid_t, :gid_t], :long

    # extern long keyctl_setperm(key_serial_t id, key_perm_t perm);
    attach_function :keyctl_setperm, [:key_serial_t, :key_perm_t], :long

    # extern long keyctl_describe(key_serial_t id, char *buffer, size_t buflen);
    attach_function :keyctl_describe, [:key_serial_t, :pointer, :size_t], :long

    # extern long keyctl_clear(key_serial_t ringid);
    attach_function :keyctl_clear, [:key_serial_t], :long

    # extern long keyctl_link(key_serial_t id, key_serial_t ringid);
    attach_function :keyctl_link, [:key_serial_t, :key_serial_t], :long

    # extern long keyctl_unlink(key_serial_t id, key_serial_t ringid);
    attach_function :keyctl_unlink, [:key_serial_t, :key_serial_t], :long

    # extern long keyctl_search(key_serial_t ringid,
    # 			  const char *type,
    # 			  const char *description,
    # 			  key_serial_t destringid);
    attach_function :keyctl_search, [:key_serial_t, :string, :string, :key_serial_t], :long

    # extern long keyctl_read(key_serial_t id, char *buffer, size_t buflen);
    attach_function :keyctl_read, [:key_serial_t, :pointer, :size_t], :long

    # extern long keyctl_instantiate(key_serial_t id,
    # 			       const void *payload,
    # 			       size_t plen,
    # 			       key_serial_t ringid);
    attach_function :keyctl_instantiate, [:key_serial_t, :pointer, :size_t, :key_serial_t], :long

    # extern long keyctl_negate(key_serial_t id, unsigned timeout, key_serial_t ringid);
    attach_function :keyctl_negate, [:key_serial_t, :uint, :key_serial_t], :long

    # extern long keyctl_set_reqkey_keyring(int reqkey_defl);
    attach_function :keyctl_set_reqkey_keyring, [:int], :long

    # extern long keyctl_set_timeout(key_serial_t key, unsigned timeout);
    attach_function :keyctl_set_timeout, [:key_serial_t, :uint], :long

    # extern long keyctl_assume_authority(key_serial_t key);
    attach_function :keyctl_assume_authority, [:key_serial_t], :long

    # extern long keyctl_get_security(key_serial_t key, char *buffer, size_t buflen);
    attach_function :keyctl_get_security, [:key_serial_t, :pointer, :size_t], :long

    # extern long keyctl_session_to_parent(void);
    attach_function :keyctl_session_to_parent, [], :long

    # extern long keyctl_reject(key_serial_t id, unsigned timeout, unsigned error,
    # 			  key_serial_t ringid);
    attach_function :keyctl_reject, [:key_serial_t, :uint, :uint, :key_serial_t], :long

    # struct iovec;
    # extern long keyctl_instantiate_iov(key_serial_t id,
    # 				   const struct iovec *payload_iov,
    # 				   unsigned ioc,
    # 				   key_serial_t ringid);
    attach_function :keyctl_instantiate_iov, [:key_serial_t, :pointer, :uint, :key_serial_t], :long

    # extern long keyctl_invalidate(key_serial_t id);
    attach_function :keyctl_invalidate, [:key_serial_t], :long

    # extern long keyctl_get_persistent(uid_t uid, key_serial_t id);
    attach_function :keyctl_get_persistent, [:uid_t, :key_serial_t], :long

    #
    # utilities
    #

    # extern int keyctl_describe_alloc(key_serial_t id, char **_buffer);
    attach_function :keyctl_describe_alloc, [:key_serial_t, :pointer], :int

    # extern int keyctl_read_alloc(key_serial_t id, void **_buffer);
    attach_function :keyctl_read_alloc, [:key_serial_t, :pointer], :int

    # extern int keyctl_get_security_alloc(key_serial_t id, char **_buffer);
    attach_function :keyctl_get_security_alloc, [:key_serial_t, :pointer], :int

    # typedef int (*recursive_key_scanner_t)(key_serial_t parent, key_serial_t key,
    #               char *desc, int desc_len, void *data);
    callback :recursive_key_scanner_t, [:key_serial_t, :key_serial_t, :pointer, :size_t, :pointer], :int

    # extern int recursive_key_scan(key_serial_t key, recursive_key_scanner_t func, void *data);
    attach_function :recursive_key_scan, [:key_serial_t, :recursive_key_scanner_t, :pointer], :int

    # extern int recursive_session_key_scan(recursive_key_scanner_t func, void *data);
    attach_function :recursive_session_key_scan, [:recursive_key_scanner_t, :pointer], :int

    # extern key_serial_t find_key_by_type_and_desc(const char *type, const char *desc,
    #                 key_serial_t destringid);
    attach_function :find_key_by_type_and_desc, [:string, :string, :key_serial_t], :key_serial_t
  end
end