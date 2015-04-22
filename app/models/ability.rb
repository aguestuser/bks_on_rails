class Ability
  include CanCan::Ability

  def initialize(account)

    account ||= Account.new
    if account.user_type == 'Staffer'
      can :manage, :all
      can :manage, :grid
      can :manage, :export
    elsif account.user_type == 'Manager'
      can [ :read, :update ], Restaurant, id: account.user.restaurant.id # own restaurant
      can [ :read, :update ], [ MiniContact,
                                RiderPaymentInfo,
                                WorkSpecification,
                                EquipmentSet,
                                AgencyPaymentInfo
                              ], restaurant_id: account.user.restaurant.id
      can [ :manage ], Manager, restaurant_id: account.user.restaurants.map(&:id) # any manager at own restaurant
      cannot [ :destroy ], Manager, id: account.user.id
      can :read, Staffer
      can :read, Shift, restaurant_id: account.user.restaurant.id
      can :read, Assignment, shift: { restaurant_id: account.user.restaurant.id }
      can [ :read, :update ], Contact, contactable_id: account.user.contact.id
      can [ :read, :update ], Account, user_id: account.user.id

      # Riders blocked
    elsif account.user_type == 'Rider'
      can [ :read, :update ], Rider, :id => account.user.id
      can [ :read, :update ], [ Contact, EquipmentSet ]
      can :read, Staffer
      can :read, Assignment, rider_id: account.user.id
      can :read, Shift, assignment: { rider_id: account.user.id }
      can [ :read, :update ], Contact, contactable_id: account.user.contact.id
      can [ :read, :update ], Account, user_id: account.user.id
      # Restaurants, Managers, Shifts blocked
    else can [:create, :preview_batch, :batch_clone, :batch_new, :batch_create, :do_batch_create, :confirm_submission], Conflict
    end
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
